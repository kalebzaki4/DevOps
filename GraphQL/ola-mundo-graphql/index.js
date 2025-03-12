const express = require('express');
const { ApolloServer, gql } = require('apollo-server-express');

const schema = gql(`
  type Query {
    OlaMundo: String!
  }
`);

const resolvers = {
    Query: {
        olaMundo: () => 'Olá Mundo! Nossa primeira consulta!',
    },
};

async function startServer() {
    const server = new ApolloServer({ typeDefs: schema, resolvers });
    await server.start(); 

    const app = express();
    server.applyMiddleware({ app });

    app.listen({ port: 4000 }, () =>
        console.log(`🚀 Servidor rodando em http://localhost:4000${server.graphqlPath}`)
    );
}

startServer();
