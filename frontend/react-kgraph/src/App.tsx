import React, { useState } from "react";
import { Graph } from "react-d3-graph";
import { useQuery, gql } from "@apollo/client";

import "./App.css";

const LIST_USERS_TOPICS = gql`
  {
    queryUser {
      name
      rootTopics {
        name
        text
        childTopics {
          name
          text
        }
      }
    }
  }
`;

interface RootTopic {
  name: string;
  text: string;
  childTopics: ChildTopic[];
}

interface ChildTopic {
  name: string;
  text: string;
}

interface QueryUser {
  name: string;
  rootTopics: RootTopic[];
}

interface QueryUserTopics {
  queryUser: QueryUser[];
}

interface GraphData {
  nodes: { id: string; text: string }[];
  links: { source: string; target: string }[];
}

const nodeData = {
  nodes: [{ id: "Harry" }, { id: "Sally" }, { id: "Alice" }],
  links: [
    { source: "Harry", target: "Sally" },
    { source: "Harry", target: "Alice" },
  ],
};

const myConfig = {
  nodeHighlightBehavior: true,
  node: {
    color: "lightgreen",
    size: 120,
    highlightStrokeColor: "blue",
  },
  link: {
    highlightColor: "lightblue",
  },
};

const generateNodes = (rootTopics?: RootTopic[]): GraphData => {
  if (!rootTopics) return nodeData as GraphData;
  let nodesObj: GraphData = {
    nodes: [],
    links: [],
  };
  rootTopics?.forEach((root) => {
    nodesObj.nodes.push({ id: root.name, text: root.text });
    root.childTopics.forEach((child) => {
      nodesObj.nodes.push({ id: child.name, text: root.text });
      nodesObj.links.push({ source: root.name, target: child.name });
    });
  });

  return nodesObj;
};

const onMouseOverNode = (
  nodeId: any,
  graphData: GraphData,
  setSelectedNodeText: React.Dispatch<React.SetStateAction<string | undefined>>
) => {
  // graphData.nodes.filter((x) => x.id === nodeId).text;
  console.log(graphData);
  setSelectedNodeText(
    graphData.nodes.filter((x: any) => x.id === nodeId)[0].text
  );
};

function App() {
  const [selectedUser, setSelectedUser] = useState<QueryUser>();
  const [selectedNodeText, setSelectedNodeText] = useState<string>();
  const { loading, error, data } = useQuery<QueryUserTopics>(LIST_USERS_TOPICS);
  // console.log(loading, error, data);

  if (loading) return <p>Loading...</p>;
  if (error || !data) return <p>Error :(</p>;

  const { queryUser } = data;

  // console.log("Query", data);
  // console.log("Selected User", selectedUser);

  const graphData = generateNodes(selectedUser?.rootTopics);

  return (
    <div className="App">
      <header className="header">
        <h1> Knowledge Graph </h1>
        {queryUser.map((user, i) => (
          <p
            key={i}
            style={{ marginRight: "10px" }}
            onClick={() => setSelectedUser(user)}
          >
            {user.name}
          </p>
        ))}
      </header>
      {/* <div>
        <ul>
          {selectedUser?.rootTopics.map((rootTopic) => (
            <li key={rootTopic.name}>{rootTopic.name}</li>
          ))}
        </ul>
      </div> */}
      <Graph
        id="graph-id"
        data={generateNodes(selectedUser?.rootTopics)}
        config={myConfig}
        onMouseOverNode={(id: string) =>
          onMouseOverNode(id, graphData, setSelectedNodeText)
        }
      />
      <h1>{selectedNodeText}</h1>
    </div>
  );
}

export default App;
