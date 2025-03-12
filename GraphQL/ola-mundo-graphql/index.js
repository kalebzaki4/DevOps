const express = require('express')
const { ApolloServer, graphql, gql } = require('apollo-server-express')

const schema = gql(`
  type Query {
     olaMundo: String!
  }
  `);

const resolver = {
    Query: {
        olaMundo: () => 'Olá Mundo! Nossa primeira consulta!'
    }
};

const server = new ApolloServer({ typeDefs: schema, resolvers: resolver });

const app = express()
server.applyMiddleware({ app })

app.listen({ port: 4000 }, () => console.log(`Server rodando no http://localhost:4000${server.graphqlPath}`))