<template>
  <v-app id="inspire">
    <v-app-bar
      app
      color="white"
      flat
    >
      <v-container class="py-0 fill-height">
        <v-avatar
          class="mr-10"
          color="blue darken-1"
          size="32"
          width="120"
          rounded="xl"
        >
        {{ selectedUser }}
        </v-avatar>

        <!-- <v-btn text> Dashboard </v-btn> -->
        <!-- <v-btn text> Profile </v-btn> -->
        <v-btn text @click="onLogout();"> Logout </v-btn>

        <v-spacer></v-spacer>

        <v-responsive max-width="260">
          <v-text-field
            v-model="topicName"
            placeholder="Type a topic name or content"
            dense
            flat
            hide-details
            rounded
            solo-inverted
          ></v-text-field>
          <ApolloQuery
            v-if="topicName != prevTopicName && selectedUser != '' && ! this.demoMode"
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
                {{ getTopics(data, topicName == '') }} {{ buildVisGraph() }}
              </div>
              <!-- No result -->
              <div v-else class="no-result apollo">No result :(</div>
            </template>
        </ApolloQuery>
        </v-responsive>
      </v-container>
    </v-app-bar>

    <v-main class="grey lighten-3">
      <v-container fluid>
        <!-- Topics Graph -->
        <v-row>
          <!-- Topics Panel -->
          <v-col cols="2">
            <v-sheet rounded="lg">
              <v-list color="transparent">
                <v-list-item
                  link
                  color="grey lighten-4"
                >
                  <v-list-item-content>
                    <v-list-item-title>
                      TOPIC DETAILS
                    </v-list-item-title>
                  </v-list-item-content>
                </v-list-item>

                <!-- <v-divider class="my-2"></v-divider> -->

                <v-card width="510px" min-height="550px">
                  <v-container>
                    <v-row>
                        <v-col cols="12">
                          <v-text-field
                            label="Topic Name"
                            required
                            v-model="addTopicName"
                          ></v-text-field>
                        </v-col>
                    </v-row>
                    <v-row>
                      <v-col align="left" cols="12">
                        <v-combobox
                          v-model="addTopicLabel"
                          :items="labelsList"
                          label="Label name"
                          full-width
                          single-line
                          small-chips
                          return-object
                          :no-filter=true
                        ></v-combobox>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col align="left" cols="12">
                          Parent Topic:
                      <treeselect
                          placeholder="None"
                          v-model="addTopicParentID"
                          :multiple="false"
                          :open-on-click="true"
                          :options="topicsList"
                      />
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <v-textarea
                          label="Content"
                          required
                          v-model="addTopicContent"
                        ></v-textarea>
                      </v-col>
                    </v-row>
                  </v-container>
                </v-card>
                  <v-list color="transparent" >
                  <template v-if="selectedNodeID == ''">
                    <v-list-item>
                      <v-row justify="center">
                        <v-btn color="primary" text @click="onAddNode(false, addTopicName, addTopicContent, addTopicLabel);" >Add Topic</v-btn>
                      </v-row>
                    </v-list-item>
                  </template>
                  <template v-if="selectedNodeID != ''">
                    <v-list-item>
                      <v-row justify="center">
                        <v-btn
                          color="primary"
                          text
                          @click="onUpdateNode();"
                        >Update Node</v-btn>
                      </v-row>
                    </v-list-item>
                    <v-list-item>
                      <v-row justify="center">
                        <v-btn
                          color="primary"
                          text
                          @click="onDeleteNode();"
                        >Delete Node</v-btn>
                      </v-row>
                    </v-list-item>
                    <v-list-item>
                      <dialog-topic-component v-bind:addChild="selectedNodeID != ''" :topicLabel="addTopicLabel" :labelsList="labelsList" :click-function="onAddNode"></dialog-topic-component>
                    </v-list-item>
                  </template>
                  </v-list>
              </v-list>
            </v-sheet>
          </v-col>
       
          <!-- https://vuetifyjs.com/en/components/grids/#grow-and-shrink -->
          <v-col cols="10">
              <!-- https://vuetifyjs.com/en/api/v-menu/ -->
              <v-menu
                absolute
                :position-x="0"
                :position-y="0"
              >
                <!-- https://vuejs.org/v2/api/#v-on -->
                <template v-slot:activator="{ on }">
                  <v-sheet id="vis-topics-graph" v-on:click.right="on.click" onContextMenu="return false;"
                    min-height="90vh"
                    rounded="lg"
                  >
                  </v-sheet>
                </template>

                <v-list v-show="btnAddTopic">
                  <v-list-item>
                    <dialog-topic-component v-bind:addChild="selectedNodeID != ''" :topicLabel="addTopicLabel" :labelsList="labelsList" :click-function="onAddNode" v-show="btnAddTopic" @click="btnAddTopic = false"></dialog-topic-component>
                  </v-list-item>
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
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
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

function buildTopicLabel(topicName, topicContent){
  const label = topicContent ? topicName  + ":\n" + topicContent : topicName;
  return label;
}

function buildTopicElement(topicId, topicName, topicContent, parentID, topicLabel){
  const element = {
    id: topicId,
    // contatenate topic name and content to display in the node
    label: buildTopicLabel(topicName, topicContent),
    name: topicName,
    title: topicContent,
    parent_id : parentID,
    // https://visjs.github.io/vis-network/docs/network/groups.html
    group: topicLabel,
    // https://visjs.github.io/vis-network/docs/network/nodes.html
    shape: "box",
  }
  return element
}

function buildTopicsTree(topicsTree, topicsRelations, kgraph_topics) {
  // console.log("buildTopicsTree - topics:", kgraph_topics)
  if(Array.isArray(kgraph_topics)) {
    for (var counter = 0; counter < kgraph_topics.length; counter++) {
      // console.log(counter)
      const topic = kgraph_topics[counter];
      var topicLabel = "";
      if(Array.isArray(topic.topics_labels) &&
          topic.topics_labels.length > 0 &&
          topic.topics_labels[0].label != null &&
          topic.topics_labels[0].label.title != null){
        topicLabel = topic.topics_labels[0].label.title;
      }
      const element = buildTopicElement(topic.id, topic.name, topic.content, topic.parent_id, topicLabel);
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

function updateTopicsTree(topicsTree, topicsRelations, id, name, content, parent_id, topicLabel){
  // update element for the list
  for (let position = 0; position < topicsTree.length; position++) {
    if ( topicsTree[position].id == id) {
      topicsTree[position].name = name;
      topicsTree[position].label = buildTopicLabel(name, content);
      topicsTree[position].title = content;
      topicsTree[position].parent_id = parent_id;
      topicsTree[position].group = topicLabel;
      break;
    }
  }
  // update relations involving the updated topic
  var relationFound = false
  for (let position = 0; position < topicsRelations.length; position++) {
    if ( topicsRelations[position].from == id) {
      topicsRelations[position].to = parent_id;
      relationFound = true;
      break;
    }
  }
  // add new relation
  if(parent_id != null && !relationFound){
      const relation = {
      from: id,
      to: parent_id
    }
    topicsRelations.push(relation);
  }
}

function addTreeTopic(topicsTree, topicsRelations, id, name, content, parent_id, topicLabel){
  const element = buildTopicElement(id, name, content, parent_id, topicLabel);
  topicsTree.push(element);
  // add new relation for child topics
  if (parent_id != null) {
    const relation = {
      from: id,
      to: parent_id
    }
    topicsRelations.push(relation);
  }
}

function deleteTreeTopic(topicsTree, topicsRelations, id){
  for (let position = 0; position < topicsTree.length; position++) {
    if ( topicsTree[position].id == id) {
        topicsTree.splice(position, 1);
        break;
    }
  }
  // remove relations involving the deleted topic
  for (let position = 0; position < topicsRelations.length; position++) {
    if ( topicsRelations[position].from == id || topicsRelations[position].to == id ) {
        topicsRelations.splice(position, 1); 
        break;
    }
  }
}

function buildTopicsList(topicsList, labelsList, kgraph_topics) {
  // console.log("buildTopicsList - topics: ", kgraph_topics)
  if(Array.isArray(kgraph_topics)) {
    for (var counter = 0; counter < kgraph_topics.length; counter++) {
      // console.log(counter)
      const topic = kgraph_topics[counter];
      var topicLabel = ""
      if(Array.isArray(topic.topics_labels) &&
        topic.topics_labels.length > 0 &&
        topic.topics_labels[0].label != null &&
        topic.topics_labels[0].label.title != null) {
          topicLabel = topic.topics_labels[0].label.title;
      }
      const element = {
        id: topic.id,
        label: topic.name,
        group: topicLabel
      }
      topicsList.push(element);
      // check if label is set and not already present in the list
      if(topicLabel != "" && labelsList.indexOf(topicLabel)) {
        console.log("labelsList.push: ", topicLabel)
        labelsList.push(topicLabel);
      }
    }
  }
}

function updateTopicsList(topicsList, id, name) {
  for (let position = 0; position < topicsList.length; position++) {
    if ( topicsList[position].id == id) {
      topicsList[position].label = name;
      break;
    }
  }
}

function addListTopic(topicsList, id, name) {
  const element = {
    id: id,
    label: name
  }
  topicsList.push(element);
}

function addListLabels(labelsList, topicLabel) {
  // check if label is set and not already present in the list
  if(topicLabel != "" && labelsList.indexOf(topicLabel)) {
    console.log("labelsList.push: ", topicLabel)
    labelsList.push(topicLabel);
  }
}

function deleteListTopic(topicsList, id){
  for (let position = 0; position < topicsList.length; position++) {
    if ( topicsList[position].id == id) {
        topicsList.splice(position, 1);
        break;
    }
  }
}

export default {
  data () {
    return {
      demoMode: false,
      username: '',
      selectedUser: '',
      topicName: '',
      topicContent: '',
      prevTopicName: ' ', // developer note -> initialized as space or not empty string
      topicAddedResult: '',
      // vue-treeselect
      topicsList: [],
      labelsList: [],
      // vis-network
      topics: [],
      topicsRelations: [],
      network: null,
      // nodes: new DataSet([{ id: "1", label: "Example topic 1" }, { id: "2", label: "Example topic 2" }]),
      nodes: new DataSet([]),
      // edges: new DataSet([{ id: "1", from: "1", to: "2" }]),
      edges: new DataSet([]),
      displayOptions: {
        configure: {
          enabled: false, // https://visjs.github.io/vis-network/docs/network/configure.html
        },
        layout: {
          hierarchical: {
            enabled: true,
            direction: 'DU',
            sortMethod: "directed"
          },
        },
        interaction: {
          selectable: true,
          hover: true,
          tooltipDelay: 100,
          zoomView: true,
        },
        manipulation: {
          // original menu https://visjs.github.io/vis-network/docs/network/manipulation.html
          enabled: false,
          initiallyActive: false,
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
      btnAddTopic: true,
      selectedNodeID: '',
      addTopicName: '',
      addTopicContent: '',
      addTopicParentID: '',
      addTopicLabel: '',
    }
  },
  created() {
    this.network = null;
    //this.$route.query.username;

    // frontend only mode (demo)
    const noBackend = process.env.VUE_APP_NO_BACKEND || false;
    console.log("created - VUE_APP_NO_BACKEND:%s", noBackend)
    if(noBackend) {
      this.demoMode = true;
      this.selectedUser = "demo";
      return;
    }

    if (window.sessionStorage.getItem('auth_token')) {
      this.selectedUser = window.sessionStorage.getItem('username');
    } else {
      this.$router.push( {path: '/' });
    }
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
    resetTopicFields(){
      this.selectedNodeID = '';
      this.addTopicName = '';
      this.addTopicContent = '';
      this.addTopicParentID = '';
      this.addTopicLabel = '';
    },
    setTopicFields(addTopicName, addTopicContent, selectedNodeID, addTopicParentID, addTopicLabel){
      this.addTopicName = addTopicName;
      this.addTopicContent = addTopicContent;
      this.selectedNodeID = selectedNodeID;
      this.addTopicParentID = addTopicParentID;
      this.addTopicLabel = addTopicLabel;
    },
    getTopics(data, rebuildTopicsList) {
      console.log("getTopics()");
      // console.log(data);
      // build the graph structure
      let topicsTree = [];
      let topicsRelations = [];
      buildTopicsTree(topicsTree, topicsRelations, data.kgraph_topics)
      // set the new structure
      this.topics = topicsTree;
      this.topicsRelations = topicsRelations;
      // build the List for the treeselect combo
      if(rebuildTopicsList) {
        let topicsList = [];
        let labelsList = [];
        buildTopicsList(topicsList, labelsList, data.kgraph_topics);
        this.topicsList = topicsList;
        this.labelsList = labelsList;
      }
    },
    onLogout() {
      this.selectedUser = ""
      window.sessionStorage.clear();
      this.$router.push( {path: '/' });
    },
    onTopicAdded: function (data) {
      this.topicAddedResult = "onTopicAdded at: " + data.data.insert_kgraph_topics.returning[0].created_at
    },
    onTreeSelectNode(node, instanceId) {
      console.log("onTreeSelectNode node: ", node, " instanceId: ", instanceId);

      const topic = this.topics.find(obj => obj.id == node.id);
      this.setTopicFields(topic.name, topic.title, topic.id, topic.parent_id, topic.group);
      this.network.selectNodes([node.id]);
    },
    onTreeDeselect(){
      console.log("onTreeDeselect")
      this.resetTopicFields();
    },
    onSelectNode(event) {
      const node = this.nodes.get(event.nodes[0]);
      console.log("onSelectNode event: ", event, " node: ", node);

      const topic = this.topics.find(obj => obj.id == node.id);
      console.log("onSelectNode - topic:", topic)
      this.setTopicFields(topic.name, topic.title, topic.id, topic.parent_id, topic.group);
    },
    onClick(event){
      console.log("onClick event: ", event);
      if (event.nodes.length == 0) {
        this.resetTopicFields();
      }
    },
    async onUpdateNode(){ 
      console.log("onUpdateNode - nodeID:", this.selectedNodeID);
      if (this.addTopicName == '') {
        alert("Fill in all the required fields!");
        return;
      }
      console.log("onUpdateNode - addTopicLabel:", this.addTopicLabel);

      if (!this.demoMode) {
        try {
          await this.$apollo.mutate({
            mutation: require('../graphql/UpdateTopicForUser.gql'),
            variables: {
              topicName: this.addTopicName,
              content: this.addTopicContent,
              username: this.selectedUser,
              id: this.selectedNodeID,
              parent_id: this.addTopicParentID,
              topicLabel: this.addTopicLabel,
            }
          })
        }
        catch (error) {
          console.error(error.message);
          alert(error.message);
          return;
        }
      }
      // update element for the list
      updateTopicsTree(this.topics, this.topicsRelations, this.selectedNodeID, this.addTopicName, this.addTopicContent, this.addTopicParentID, this.addTopicLabel);
      updateTopicsList(this.topicsList, this.selectedNodeID, this.addTopicName);

      // redraw
      this.buildVisGraph();
    },
    async onDeleteNode(){
      console.log("onDeleteNode - nodeID:", this.selectedNodeID)
      if (this.selectedNodeID == '') {
        alert("No selected node found!");
        return;
      }

      if (!this.demoMode) {
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
      }

      // remove element from the topic list
      deleteTreeTopic(this.topics, this.topicsRelations, this.selectedNodeID);
      deleteListTopic(this.topicsList, this.selectedNodeID);

      // reset fields
      this.resetTopicFields();

      // redraw
      this.buildVisGraph();
    },
    async onAddNode(child, addTopicName, addTopicContent, addTopicLabel){ 
      console.log("onAddNode: child[%s], addTopicName[%s], addTopicContent[%s], selectedNodeID[%s], addTopicLabel[%s]", child, addTopicName, addTopicContent, this.selectedNodeID, this.addTopicLabel);
      if (addTopicName == '') {
        alert("Fill in all the required fields!");
        return;
      }

      this.addTopicName = addTopicName;
      this.addTopicContent = addTopicContent;
      this.addTopicParentID = (child ? this.selectedNodeID : null)
      this.addTopicLabel = addTopicLabel;

      if (!this.demoMode) {
        var result = null;
        try {
          if(this.addTopicLabel == "") {
            result = await this.$apollo.mutate({
              mutation: require('../graphql/AddTopicForUser.gql'),
              variables: {
                topicsName: this.addTopicName,
                content: this.addTopicContent,
                parent_id: (child ? this.selectedNodeID : null)
              }
            })
          } else {
            result = await this.$apollo.mutate({
              mutation: require('../graphql/AddTopicLabelForUser.gql'),
              variables: {
                topicsName: this.addTopicName,
                content: this.addTopicContent,
                parent_id: (child ? this.selectedNodeID : null),
                topicLabel: this.addTopicLabel
              }
            })
          }
        }
        catch (error) {
          console.error(error.message);
          alert(error.message);
          return;
        }

        // { "data": { "insert_kgraph_topics": { "returning": [ { "created_at": "2021-01-31T12:23:53.124938+00:00", "__typename": "kgraph_topics" } ], "__typename": "kgraph_topics_mutation_response" } } }
        this.topicAddedResult = result.data.insert_kgraph_topics.returning[0].id
      } else {
        // use topic name as ID
        this.topicAddedResult = this.addTopicName;
      }

      // close the add Dialog
      this.btnAddTopic = false;

      // add new topic to the list
      addTreeTopic(this.topics, this.topicsRelations, this.topicAddedResult, this.addTopicName, this.addTopicContent, (child ? this.selectedNodeID : null), this.addTopicLabel);
      addListTopic(this.topicsList, this.topicAddedResult, this.addTopicName);
      addListLabels(this.labelsList, this.addTopicLabel);

      // reset fields
      this.resetTopicFields();

      // redraw
      this.buildVisGraph();
    },
    onEditNode(event) {
      const node = this.nodes.get(event.nodes[0]);
      console.log("onEditNode event: ", event, " node: ", node);
    },
    onNetworkContext(params) {
      console.log("onContext:", params);
      params.event.preventDefault();
      params.event = "[original event]";
      // document.getElementById("eventSpanContent").innerText = JSON.stringify(params, null, 4 );
      this.selectedNodeID = params.nodes.length > 0 ? params.nodes[0] : '';
      console.log("selectedNodeID:", this.selectedNodeID);
      this.btnAddTopic = true;
    },
    buildVisGraph() {
      console.log("buildVisGraph");
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
      this.network.setSize(element.clientWidth, element.clientHeight);
      // this.network.stopSimulation();
      // https://github.com/visjs/vis-network/blob/master/examples/network/events/interactionEvents.html
      this.network.on('selectNode', event => this.onSelectNode(event));
      this.network.on('click', event => this.onClick(event));
      this.network.on("doubleClick", function(data) {
        console.log("doubleClick: ", data);
      });
      // fired when the user click on the canvas with the right mouse button. The right mouse button does not select by default. You can use the method getNodeAt to select the node if you want.
      this.network.on("oncontext", this.onNetworkContext);
    },
  },
}
</script>

<style scoped>

.error {
  color: red;
}

</style>-