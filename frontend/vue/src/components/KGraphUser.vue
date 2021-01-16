<template>
  <div class="kgraphuser">
    <ul>
      <li>
        <!-- list all users -->
        <ApolloQuery :query="require('../graphql/ListUsers.gql')">
          <div slot-scope="{ result: { data } }">
            <label for="select-name" class="label">Select user</label>
            <template v-if="data">
              <select v-model="selectedUser" id="select-name">
                <option
                  v-for="user of data.kgraph_users"
                  :key="user.username"
                  v-bind:value="user.username"
                >
                  {{ user.username }}
                </option>
              </select>
              <div>Selected: {{ selectedUser }}</div>
            </template>
          </div>
        </ApolloQuery>
      </li>
    </ul>
    <ul>
      <li>
        <!-- add topic for user -->
        <ApolloMutation
          :mutation="require('../graphql/AddTopicForUser.gql')"
          :variables="{
            topicsName: topicName,
            username: selectedUser
          }"
          @done="onTopicAdded"
        >
          <template slot-scope="{ mutate, error}">
            <!-- Mutation Trigger -->
            <label class="label">Add new root topic</label>
            <input v-model="topicName" type="text" placeholder="Topic name" />
            <button @click="mutate()">Add Topic</button>
            <!-- Error -->
            <p v-if="error">{{ error }}</p>
            <!-- result -->
            <p> {{ topicAddedResult }}</p>
          </template>
        </ApolloMutation>
      </li>
      <li>
        <!-- search topic for user -->
          <div class="form">
            <label for="field-name" class="label">Find topics for user {{ selectedUser }}:</label>
            <input
              v-model="topicName"
              placeholder="Type a topic name"
              class="input"
              id="field-name"
            >
          </div>
          <ApolloQuery
            v-if="topicName != prevTopicName && selectedUser != ''"
            :query="require('../graphql/SearchTopicsForUser.gql')"
            :variables="{ topicsName: '%'+topicName+'%', username: selectedUser }"
          >
            <template slot-scope="{ result: { loading, error, data } }">
              <!-- Loading -->
              <div v-if="loading" class="loading apollo">Loading...</div>

              <!-- Error -->
              <div v-else-if="error" class="error apollo">{{ error }}</div>

              <!-- Result -->
              <div v-else-if="data != null" class="result apollo">
                {{ prevTopicName = topicName }}
                <!-- {{ data }} -->
                {{ getTopics(data) }} {{ buildVisGraph() }}
              </div>
              <!-- No result -->
              <div v-else class="no-result apollo">No result :(</div>
            </template>
        </ApolloQuery>
      </li>
    </ul>
    <ul>
      <li>
        <div id="vis-topics-graph"></div> 
      </li>
      <li>
        <div id="vuetreeselect">
          Topics list:
          <!-- https://github.com/rangowuchen/ElementUIExample/blob/696672475cf35e2eee29cbdca518226c37e371b8/src/pages/vue-treeselect/components/moreFunction.vue -->
          <treeselect
            :multiple="true"
            :open-on-click="true"
            :options="topics"
          />
        </div>
      </li>
    </ul>
    
  </div>
</template>

<script>
// https://github.com/riophae/vue-treeselect
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

// https://github.com/visjs/vis-network
import { Network } from "vis-network/peer/esm/vis-network";
import { DataSet } from "vis-data/peer/esm/vis-data"

// to consider: https://doc.mindelixir.ink/index.html - https://codesandbox.io/s/hygz7?file=/src/App.vue

function buildTopicsTree(topicsTree, topicsRelations, kgraph_topics) {
  // console.log(kgraph_topics)
  if(Array.isArray(kgraph_topics)) {
    for (var counter = 0; counter < kgraph_topics.length; counter++) {
      // console.log(counter)
      const topic = kgraph_topics[counter];
      const element = {
        id: topic.id,
        label: topic.name,
      }
      if (topic.parent_id != null) {
        // console.log("topic id:" + topic.id + " parent: " + topic.parent_id)
        const relation = {
          id: topic.id,
          from: topic.id,
          to: topic.parent_id
        }
        topicsRelations.push(relation);
      }
      topicsTree.push(element);
    }
  }
}

export default {
  data () {
    return {
      username: '',
      selectedUser: '',
      topicName: '',
      prevTopicName: ' ', // developer note -> initialized as space or not empty string
      topicAddedResult: '',
      // vue-treeselect
      topics: [],
      topicsRelations: [],
      // vis-network
      network: null,
      // nodes: new DataSet([{ id: "1", label: "Example topic 1" }, { id: "2", label: "Example topic 2" }]),
      nodes: new DataSet([]),
      // edges: new DataSet([{ id: "1", from: "1", to: "2" }]),
      edges: new DataSet([]),
      displayOptions: { }
    }
  },
  created() {
    this.network = null;
  },
  mounted() {
    this.buildVisGraph()
  },
  beforeDestroy() {
    if (this.network) {
      this.network.destroy();
    }
  },
  computed: {
  },
  // register the component
  components: { Treeselect },
  methods: {
    onTopicAdded: function (data) {
      this.topicAddedResult = "Topic created at: " + data.data.insert_kgraph_topics.returning[0].created_at
    },
    getTopics(data) {
      console.log("---- getTopics() ---");
      console.log(data);
      let topicsTree = [];
      let topicsRelations = [];
      buildTopicsTree(topicsTree, topicsRelations, data.kgraph_topics)
      this.topics = topicsTree;
      this.topicsRelations = topicsRelations;
    },
    buildVisGraph() {
      console.log("buildVisGraph")
      if (this.network) {
          this.network.destroy();
          this.network = null;
          // this.nodes.clear();
          // this.edges.clear();
      } 
      this.nodes = new DataSet(this.topics)
      this.edges = new DataSet(this.topicsRelations);
      let data = {
        nodes: this.nodes,
        edges: this.edges
      };
      const element = document.getElementById('vis-topics-graph');
      this.network = new Network(element, data, this.displayOptions);
      // this.network.enableEditMode();
      // this.network.stopSimulation();
      // network.on('selectNode', event => this.onSelectNode(network, event));
    },
  },
}
</script>

<style scoped>
.form,
.input,
.apollo,
.message {
  padding: 12px;
}

label {
  display: block;
  margin-bottom: 6px;
}

.input {
  font-family: inherit;
  font-size: inherit;
  border: solid 2px #ccc;
  border-radius: 3px;
}

.error {
  color: red;
}

.images {
  display: grid;
  grid-template-columns: repeat(auto-fill, 300px);
  grid-auto-rows: 300px;
  grid-gap: 10px;
}

.image-item {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ccc;
  border-radius: 8px;
}

.image {
  max-width: 100%;
  max-height: 100%;
}

.image-input {
  margin: 20px;
}

ul {
  list-style-type: none;
  text-align: center;
  white-space: nowrap;
}
li {
  display: table-cell;
  position: relative;
  box-sizing: border-box;
  overflow: visible;
  padding: 50px;
  /* to center alignment everything */
  display: flex;
  justify-content: center;
}

#vis-topics-graph {
  width: 1024px;
  height: 400px;
  border: 1px solid lightgray;
}
</style>
