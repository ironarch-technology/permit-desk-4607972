class PermitDeskSchema < GraphQL::Schema
  query Types::QueryType
  mutation Types::MutationType

  max_depth 12
  max_complexity 200
end
