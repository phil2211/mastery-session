// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { MongoClient } from "mongodb";
import axios from 'axios';

const secret_name = "swisscom-masteryfriday-connectionstring";

const secretsManagerClient = new SecretsManagerClient({
  region: "eu-central-1",
});

let response;

try {
  response = await secretsManagerClient.send(
    new GetSecretValueCommand({
      SecretId: secret_name,
      VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
    })
  );
} catch (error) {
  // For a list of exceptions thrown, see
  // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
  throw error;
}

const secretString = response.SecretString;
const secret = JSON.parse(secretString);

const client = new MongoClient(secret.MongoDBConnectionString);

export const handler = async (event) => {
  console.log(event);

  const searchText = JSON.parse(event.body).searchText;
  const agg = [];
  
  if (searchText !== "") {
    const embedding = await getEmbedding(searchText);  
    agg.push({"$vectorSearch": {
          "queryVector": embedding,
          "path": "plot_embedding",
          "numCandidates": 100,
          "limit": 10,
          "index": "default"
        }})
  }

  var dbName = "sample_mflix";
  var collName = "embedded_movies";

  // Get a collection from the context
  var collection = await client.db(dbName).collection(collName);

  agg.push({
          "$project": {
            "title": 1,
            "plot": 1,
            "fullplot": 1,
            "poster": 1,
            "year": 1
        }}
  );
  
  agg.push(
        {
          "$facet": {
          "rows": [{"$skip": 0}, {"$limit": 2000}],
          "rowCount": [{"$count": 'lastRow'}]
        }}    
  );
  
  agg.push(
        {
          "$project": {
            "rows": 1,
            "lastRow": {"$ifNull": [{"$arrayElemAt": ["$rowCount.lastRow", 0]}, 0]}
        }}
  );
  
  console.log(JSON.stringify(agg));

  try {
    const documents = await collection.aggregate(agg).next();
    return {
      statusCode: 200,
      body: JSON.stringify(documents)
    }
  } catch(err) {
    console.log("Error occurred while executing findOne:", err.message);
    return {
      statusCode: 500,
      error: err.message
    };
  }
};

async function getEmbedding(query) {
    const url = 'https://api.openai.com/v1/embeddings';
    const openai_key = secret.OpenAI_APIKey;
    
    const headers = {
      'Authorization': [`Bearer ${openai_key}`],
      'Content-Type': ['application/json']
    };

    //query = "Movies with kids";

    const body = JSON.stringify({
      input: query,
      model: "text-embedding-ada-002"
    });

    console.log(headers);
    console.log(`query: ${query}`);

    // Call OpenAI API to get the embeddings.
    const response = await axios.post(url, body, { headers: headers });

    console.log(response.status);
    console.log(response.data);

    if(response.status === 200) {
        let responseData = response.data;
        return responseData.data[0].embedding;
    } else {
        throw new Error(`Failed to get embedding. Status code: ${response.status}`);
    }
}