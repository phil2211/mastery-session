// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

import {
  BedrockRuntimeClient,
  InvokeModelCommand,
} from "@aws-sdk/client-bedrock-runtime";

import { MongoClient, Double } from "mongodb";

import { Console } from 'console';
const logger = new Console({ stdout: process.stdout, stderr: process.stderr });

const bedrockClient = new BedrockRuntimeClient({ region: "eu-central-1" });

const secretsManagerClient = new SecretsManagerClient({
  region: "eu-central-1",
});

let response;

try {
  response = await secretsManagerClient.send(
    new GetSecretValueCommand({
      SecretId: process.env.SECRET_NAME,
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
const client = new MongoClient(secret.srvConnectionString);

export const handler = async (event) => {
  console.log(event);

  //const searchText = 'kids in magic school'//JSON.parse(event.body).searchText;
  const searchText = JSON.parse(event.body).searchText;
  const agg = [];
  
  if (searchText !== "") {
    const embedding = await generateEmbeddings(JSON.stringify({"inputText": searchText}));  
    agg.push({"$vectorSearch": {
          "queryVector": embedding.map(num => new Double(num)),
          "path": "eg_vector",
          "numCandidates": 100,
          "limit": 10,
          "index": "vector_index"
        }})
  }

  var dbName = "sample_mflix";
  var collName = "movies";

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
          "rows": [{"$skip": 0}, {"$limit": 20}],
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
      body: documents
    }
  } catch(err) {
    console.log("Error occurred while executing aggregate:", err.message);
    return {
      statusCode: 500,
      error: err.message
    };
  }
};


async function generateEmbeddings(body) {

  // Invoke the model with the payload and wait for the response.
  const command = new InvokeModelCommand({
    contentType: "application/json",
    body,
    modelId: 'amazon.titan-embed-text-v1',
    accept: 'application/json'
  });
  const apiResponse = await bedrockClient.send(command);

  // Decode and return the response.
  const decodedResponseBody = new TextDecoder().decode(apiResponse.body);
  const responseBody = JSON.parse(decodedResponseBody);
  console.log(responseBody);
  return responseBody.embedding.map(num => parseFloat(num)); 
}
