if ! command -v mongosh &> /dev/null
then
    echo "mongosh could not be found, please install it"
    exit
fi

if [ $# -ne 2 ]; then
    echo "Usage: create_atlas_index.sh <connection string> <username>"
    exit 1
fi
CONNECTION=$1
USER=$2

mongosh ${CONNECTION}/sample_mflix --username ${USER} --eval '
db.movies.updateSearchIndex(
    "vector_index",
    {
        mappings: {
            fields: {
                eg_vector: {
                    type: "knnVector",
                    dimensions: 1536,
                    similarity: "cosine"
                }
            }
        }
    }
);'
