import React from 'react';
import { useQuery, gql } from '@apollo/client';

import './App.css';

const Query = gql`
  {
    queryTenant { name id }
  }
`;

interface Query {
  queryTenant: [{
    id: number;
    name: string;
  }];
}

function App() {
  const { loading, error, data } = useQuery<Query>(Query);
  console.log(loading, error, data);
  return (
    <div className="App">
      {data !== undefined ? data.queryTenant.map((x: any) => <h1 key={x.id}>{x.name}</h1>) : null}
    </div>
  );
}

export default App;
