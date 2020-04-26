import React from 'react';
import { useQuery, gql } from '@apollo/client';

import './App.css';

const LIST_USERS_TOPICS = gql`
  {
    queryUser { name rootTopics { name } }
  }
`;

interface QueryUserTopics {
  queryUser: [{
    name: string,
    rootTopics: [{name : string}]
  }];
}

function App() {
  const { loading, error, data } = useQuery<QueryUserTopics>(LIST_USERS_TOPICS);
  console.log(loading, error, data);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error :(</p>;

  return (
  <div className="App">
    <header className="header">
      <h1> Knowledge Graph </h1>
        {data !== undefined ? data.queryUser.map((x: any) => <p>User:{x.name} {x.rootTopics.map((topic: any) => <div>{topic.name}</div>)}</p>) : <p>Error :(</p>}
    </header>
  </div>
);
  }

export default App;
