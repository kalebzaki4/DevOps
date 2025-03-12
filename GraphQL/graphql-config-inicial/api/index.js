const { ApolloServer, gql } = require('apollo-server');

const users = [
    { name: 'John Doe', ativo: true },
    { name: 'marcos', ativo: false }
]

const typeDefs = gql`
type User {
    nome: String!
    ativo: Boolean!
    email: String
}
`


const server = new ApolloServer({ typeDefs, resolvers });

