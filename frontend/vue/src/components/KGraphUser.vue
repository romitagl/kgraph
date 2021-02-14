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
    <table style="width:100%">
    <tr>
      <td>
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
      </td>
      <td max-width="500px" width="500px">
        <div id="vuetreeselect">
          Topics list:
          <!-- https://github.com/rangowuchen/ElementUIExample/blob/696672475cf35e2eee29cbdca518226c37e371b8/src/pages/vue-treeselect/components/moreFunction.vue -->
          <treeselect
            :multiple="false"
            :open-on-click="true"
            :options="topics"
          />
        </div>
      </td>
    </tr>
    </table>
    </ul>
    <ul>
      <li>
        <!-- https://vuetifyjs.com/en/api/v-menu/ -->
        <v-menu
          absolute
          :position-x="0"
          :position-y="0"
        >
          <!-- https://vuejs.org/v2/api/#v-on -->
          <template v-slot:activator="{ on }">
            <div id="vis-topics-graph" v-on:click.right="on.click"></div>
          </template>

          <v-list>
              <!-- <v-btn text @click="onAddNode">Add Node</v-btn> --> 
              <v-dialog
                v-model="dialogAdd"
                max-width="500px"
              >
              <template v-slot:activator="{ on }">
                <v-list-item v-show="btnAddTopic">
                  <v-btn color="primary" text v-on:click="on.click" v-show="btnAddTopic" v-if="selectedNodeID == ''">Add Topic</v-btn>
                  <v-btn color="primary" text v-on:click="on.click" v-show="btnAddTopic" v-if="selectedNodeID != ''" @click="addTopicName=''; addTopicContent=''">Add Child Topic</v-btn>
                </v-list-item>
              </template>
                <v-card>
                  <v-card-title>
                    Topic Details
                  </v-card-title>
                    <v-container>
                      <v-row>
                        <v-col cols="6">
                          <v-text-field
                            label="Topic Name"
                            required
                            v-model="addTopicName"
                          ></v-text-field>
                        </v-col>
                        </v-row>
                        <v-row>
                        <v-col cols="12">
                          <v-text-field
                            label="Content"
                            required
                            v-model="addTopicContent"
                          ></v-text-field>
                        </v-col>
                      </v-row>
                    </v-container>
                  <v-card-actions>
                    <v-btn
                      color="primary"
                      text
                      @click="dialogAdd = false; btnAddTopic=false"
                    >Cancel</v-btn>
                    <v-btn
                      color="primary"
                      text
                      @click="onAddNode(selectedNodeID != '', addTopicName, addTopicContent); btnAddTopic=false"
                    >Add</v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            <template v-if="selectedNodeID != ''">
              <v-list-item v-show="btnAddTopic">
                <v-btn 
                  color="primary"
                  text
                  v-show="btnAddTopic"
                  @click="onDeleteNode();"
                >Delete Node</v-btn>
              </v-list-item>
            </template>
          </v-list>
        </v-menu>

        <!-- <pre id="eventSpanContent"></pre> -->
        <div>
          <v-card>
            <v-card-title>
              Topic Details
            </v-card-title>
              <v-container>
                <v-row>
                  <v-col cols="6">
                    <v-text-field
                      label="Topic Name"
                      required
                      v-model="addTopicName"
                    ></v-text-field>
                  </v-col>
                  </v-row>
                  <v-row>
                  <v-col cols="12">
                    <v-text-field
                      label="Content"
                      required
                      v-model="addTopicContent"
                    ></v-text-field>
                  </v-col>
                </v-row>
              </v-container>
            <v-card-actions>
              <template v-if="selectedNodeID == ''">
                <v-btn color="primary" text @click="onAddNode(false, addTopicName, addTopicContent);" >Add Topic</v-btn>
              </template>
              <template v-if="selectedNodeID != ''">
                <v-list-item>
                  <v-btn 
                    color="primary"
                    text
                    @click="onDeleteNode();"
                  >Delete Node</v-btn>
                </v-list-item>
                <v-list-item>
                  <v-btn 
                    color="primary"
                    text
                    @click="onUpdateNode();"
                  >Update Node</v-btn>
                </v-list-item>
                <dialog-topic-component :click-function="onAddNode"></dialog-topic-component>
              </template>
            </v-card-actions>
          </v-card>
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

import KGraphDialogAddTopic from "@/components/KGraph-Dialog-AddTopic.vue";

// https://vuetifyjs.com

function buildTopicsTree(topicsTree, topicsRelations, kgraph_topics) {
  // console.log(kgraph_topics)
  if(Array.isArray(kgraph_topics)) {
    for (var counter = 0; counter < kgraph_topics.length; counter++) {
      // console.log(counter)
      const topic = kgraph_topics[counter];
      const element = {
        id: topic.id,
        label: topic.name,
        title: topic.content,
        parent_id : topic.parent_id,
        // https://visjs.github.io/vis-network/docs/network/nodes.html
        shape: "ellipse",
      }
      if (topic.parent_id != null) {
        // console.log("topic id:" + topic.id + " parent: " + topic.parent_id)
        const relation = {
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
      topicContent: '',
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
      displayOptions: {
        configure: {
          enabled: false // https://visjs.github.io/vis-network/docs/network/configure.html
        },
        interaction: {
          selectable: true,
          hover: true,
          tooltipDelay: 100,
          zoomView: false,
        },
        manipulation: {
          enabled: true,
          initiallyActive: true,
          addNode: function(nodeData,callback) {
            console.log("addNode: ", nodeData)
            callback(nodeData);
          },
          editNode: function (data, callback) {
            console.log("editNode: ", data, callback)
            callback(data);
          },
        }
      },
      // right-click graph topics management
      selectedNodeID: '',
      dialogAdd: false,
      btnAddTopic: true,
      addTopicName: '',
      addTopicContent: '',
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
  components: {
    Treeselect,
    'dialog-topic-component': KGraphDialogAddTopic
    },
  methods: {
    onTopicAdded: function (data) {
      this.topicAddedResult = "onTopicAdded at: " + data.data.insert_kgraph_topics.returning[0].created_at
    },
    getTopics(data) {
      console.log("getTopics()");
      console.log(data);
      let topicsTree = [];
      let topicsRelations = [];
      buildTopicsTree(topicsTree, topicsRelations, data.kgraph_topics)
      this.topics = topicsTree;
      this.topicsRelations = topicsRelations;
    },
    onSelectNode(event) {
      const node = this.nodes.get(event.nodes[0]);
      console.log("onSelectNode event: ", event, " node: ", node);

      this.selectedNodeID = node.id;
      const topic = this.topics.find(obj => obj.id == this.selectedNodeID);
      console.log("onSelectNode - topic:", topic)
      this.addTopicName = topic.label;
      this.addTopicContent = topic.title;
    },
    onClick(event){
      console.log("onClick event: ", event);
      if (event.nodes.length == 0) {
        this.selectedNodeID = '';
        this.addTopicName = '';
        this.addTopicContent = '';
      }
    },
    async onUpdateNode(){ 
      console.log("onUpdateNode - nodeID:", this.selectedNodeID);
      if (this.addTopicName == '') {
        alert("Fill in all the required fields!");
        return;
      }

      try {
        await this.$apollo.mutate({
          mutation: require('../graphql/UpdateTopicForUser.gql'),
          variables: {
            topicName: this.addTopicName,
            content: this.addTopicContent,
            username: this.selectedUser,
            id: this.selectedNodeID
          }
        })
      }
      catch (error) {
        console.error(error.message);
        alert(error.message);
        return;
      }

      // update element for the list
      for (let position = 0; position < this.topics.length; position++) {
        if ( this.topics[position].id == this.selectedNodeID) {
          this.topics[position].label = this.addTopicName;
          this.topics[position].title = this.addTopicContent;
        }
      }

      // redraw
      this.buildVisGraph();
    },
    async onDeleteNode(){ 
      console.log("onDeleteNode - nodeID:", this.selectedNodeID)
      if (this.selectedNodeID == '') {
        alert("No selected node found!");
        return;
      }
      try {
        await this.$apollo.mutate({
          mutation: require('../graphql/DeleteTopicForUser.gql'),
          variables: {
            topicID: this.selectedNodeID,
            username: this.selectedUser
          }
        })
      }
      catch (error) {
        console.error(error.message);
        alert(error.message);
        return;
      }

      // remove element from the topic list
      let parent_id = null;
      for (let position = 0; position < this.topics.length; position++) {
        if ( this.topics[position].id == this.selectedNodeID) {
            parent_id = this.topics[position].parent_id;
            this.topics.splice(position, 1);
            break;
        }
      }
      // remove relation for child topic
      if (parent_id != null) {
        for (let position = 0; position < this.topicsRelations.length; position++) {
          if ( this.topicsRelations[position].from == this.selectedNodeID && this.topicsRelations[position].to == parent_id) {
              this.topicsRelations.splice(position, 1); 
              break;
          }
        }
      }

      // reset fields
      this.selectedNodeID = '';
      this.addTopicName = '';
      this.addTopicContent = '';

      // redraw
      this.buildVisGraph();
    },
    async onAddNode(child, addTopicName, addTopicContent){ 
      if (addTopicName == '') {
        alert("Fill in all the required fields!");
        return;
      }

      this.addTopicName = addTopicName;
      this.addTopicContent = addTopicContent;

      var result = null;
      try {
        result = await this.$apollo.mutate({
          mutation: require('../graphql/AddTopicForUser.gql'),
          variables: {
            topicsName: this.addTopicName,
            content: this.addTopicContent,
            username: this.selectedUser,
            parent_id: (child ? this.selectedNodeID : null)
          }
        })
      }
      catch (error) {
        console.error(error.message);
        alert(error.message);
        return;
      }

      // { "data": { "insert_kgraph_topics": { "returning": [ { "created_at": "2021-01-31T12:23:53.124938+00:00", "__typename": "kgraph_topics" } ], "__typename": "kgraph_topics_mutation_response" } } }
      this.topicAddedResult = result.data.insert_kgraph_topics.returning[0].id
      // close the add Dialog
      this.dialogAdd = false;

      // add new topic to the list
      const element = {
        id: this.topicAddedResult,
        label: this.addTopicName,
        title: this.addTopicContent,
        parent_id: (child ? this.selectedNodeID : null)
      }
      this.topics.push(element);
      // add new relation for child topics
      if (child) {
        const relation = {
          from: element.id,
          to: element.parent_id
        }
        this.topicsRelations.push(relation);
      }

      // reset fields
      this.addTopicName = '';
      this.addTopicContent = '';

      // redraw
      this.buildVisGraph();
    },
    onEditNode(event) {
      const node = this.nodes.get(event.nodes[0]);
      console.log("onEditNode event: ", event, " node: ", node)
    },
    onNetworkContext(params) {
      console.log("onContext:", params)
      params.event.preventDefault();
      params.event = "[original event]";
      // document.getElementById("eventSpanContent").innerText = JSON.stringify(params, null, 4 );
      this.selectedNodeID = params.nodes.length > 0 ? params.nodes[0] : '';
      console.log("selectedNodeID:", this.selectedNodeID)
      this.btnAddTopic = true;
    },
    buildVisGraph() {
      console.log("buildVisGraph")
      if (this.network) {
        this.network.destroy();
        this.network = null;
        this.nodes.clear();
        this.edges.clear();
      }
      // https://visjs.github.io/vis-data/data/dataset.html
      this.nodes = new DataSet(this.topics);
      this.edges = new DataSet(this.topicsRelations);
      let data = {
        nodes: this.nodes,
        edges: this.edges
      };
      const element = document.getElementById('vis-topics-graph');
      this.network = new Network(element, data, this.displayOptions);
      this.network.enableEditMode();
      // this.network.stopSimulation();
      // https://github.com/visjs/vis-network/blob/master/examples/network/events/interactionEvents.html
      this.network.on('selectNode', event => this.onSelectNode(event));
      this.network.on('click', event => this.onClick(event));
      this.network.on("doubleClick", function(data) {
        console.log("doubleClick: ", data)
      });
      // Fired when the user click on the canvas with the right mouse button. The right mouse button does not select by default. You can use the method getNodeAt to select the node if you want.
      this.network.on("oncontext", this.onNetworkContext)
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

.input, input, option, select {
  font-family: inherit;
  font-size: inherit;
  border: solid 2px rgb(136, 126, 126);
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

td, ul {
  list-style-type: none;
  text-align: center;
  white-space: nowrap;
}
tr, li {
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
