<template>
  <div class="vue-kgraph">
    <ul>
      <li>
        <!-- list all users -->
        <ApolloQuery :query="require('../graphql/QueryUsers.gql')">
          <div slot-scope="{ result: { data } }">
            <label for="select-name" class="label">Select user</label>
            <template v-if="data">
              <select v-model="selectedUser" id="select-name">
                <option
                  v-for="user of data.queryUser"
                  :key="user.name"
                  v-bind:value="user.name"
                >
                  {{ user.name }}
                </option>
              </select>
              <div>Selected: {{ selectedUser }}</div>
            </template>
          </div>
        </ApolloQuery>
        <ApolloMutation
          :mutation="require('../graphql/RemoveUser.graphql')"
          :variables="{
            name: selectedUser,
          }"
          @done="selectedUser = 'Deleted'"
        >
          <template slot-scope="{ mutate, error }">
            <!-- Mutation Trigger -->
            <button @click="mutate()">Delete User</button>

            <!-- Error -->
            <p v-if="error">{{ error }}</p>
          </template>
        </ApolloMutation>
      </li>

      <li>
        <!-- add new user -->
        <ApolloMutation
          :mutation="require('../graphql/AddUser.graphql')"
          :variables="{
            name: newUser,
          }"
          @done="
            getUser = newUser;
            newUser = '';
          "
        >
          <template slot-scope="{ mutate, error }">
            <!-- Mutation Trigger -->
            <label class="label">Create new user</label>
            <input v-model="newUser" type="text" placeholder="getUser" />

            <button @click="mutate()">Add User</button>

            <!-- Error -->
            <p v-if="error">{{ error }}</p>
          </template>
        </ApolloMutation>
      </li>

      <li>
        <!-- Cute tiny form -->
        <div class="form">
          <label for="field-name" class="label">Find user</label>
          <input
            v-model="getUser"
            placeholder="Type a name"
            class="input"
            id="field-name"
          />
        </div>

        <!-- retrieve single user -->
        <ApolloQuery
          v-if="getUser"
          :query="require('../graphql/GetUser.gql')"
          :variables="{ name: getUser }"
        >
          <template slot-scope="{ result: { error, data } }">
            <!-- Error -->
            <div v-if="error" class="error apollo">An error occured</div>

            <!-- Result -->
            <div v-else-if="data" class="result apollo">
              {{ data.getUser.name }}
            </div>

            <!-- No result -->
            <div v-else class="no-result apollo">No result :(</div>
          </template>
        </ApolloQuery>
      </li>
    </ul>

    <ul>
      <li>
        <ApolloQuery
          v-if="selectedUser != prevSelectedUser"
          :query="require('../graphql/GetUser.gql')"
          :variables="{ name: selectedUser }" 
        >
          <template slot-scope="{ result: { error, data } }">
            <!-- Error -->
            <div v-if="error" class="error apollo">An error occured {{ prevSelectedUser = selectedUser }}</div>

            <!-- Result -->
            <div v-else-if="data" class="result apollo">
              {{ prevSelectedUser = selectedUser }}
              {{ getTopics(data) }}
            </div>

            <!-- No result -->
            <div v-else class="no-result apollo">No result :(</div>
          </template>
        </ApolloQuery>
      </li>
    </ul>
    <ul>
      <li>
        <div id="app">
          <!-- https://github.com/rangowuchen/ElementUIExample/blob/696672475cf35e2eee29cbdca518226c37e371b8/src/pages/vue-treeselect/components/moreFunction.vue -->
          <treeselect
            :multiple="true"
            :open-on-click="openOnClick"
            :options="topics"
          />
        </div>
        <p>
          <label
            ><input type="checkbox" v-model="openOnClick" />Open on click</label
          >
        </p>
      </li>
    </ul>
    <ul>
      <div id="map" style="width: 100%; height: 500px"></div>
    </ul>
  </div>
</template>

<script>
// https://github.com/riophae/vue-treeselect
import Treeselect from "@riophae/vue-treeselect";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";

import "regenerator-runtime";
import MindElixir from "mind-elixir";

// to try: https://github.com/ondras/my-mind
// to try: https://github.com/Mindmapp/mindmapp
// https://github.com/ssshooter/mind-elixir-core

const meData = {
  el: "#map",
  direction: MindElixir.SIDE,
  data: { nodeData: { id: 'root',
          topic: 'Knowledge Graph',
          root: true,
          children:[] } },
  draggable: true, // default true
  contextMenu: true, // default true
  toolBar: true, // default true
  nodeMenu: true, // default true
  keypress: true, // default true
};

function buildTopicsTree(childrenArr, rootTopics, isTopic) {
  // console.log(rootTopics)
  if(Array.isArray(rootTopics)) {
    for (var counter = 0; counter < rootTopics.length; counter++) {
      // console.log(counter)
      const topic = rootTopics[counter];
      let recursiveChildren = [];
      if(Array.isArray(topic.childTopics)) {
        // console.log("array - childTopics.length: " + topic.childTopics.length)
        if (topic.childTopics.length > 0) {
          buildTopicsTree(recursiveChildren, topic.childTopics, isTopic);
        }
      }
      const children = isTopic ? {
        id: topic.id,
        topic: topic.name,
        children: recursiveChildren
      } : {
        id: topic.id,
        label: topic.name,
        children: recursiveChildren
      }
      childrenArr.push(children);
    }
  } // child element
  else {
    const children = isTopic ? {
      id: rootTopics.id,
      topic: rootTopics.name,
    } : {
      id: rootTopics.id,
      label: rootTopics.name,
    }
    childrenArr.push(children);
  }
}

export default {
  // register the component
  components: { Treeselect },
  methods: {
    getTopics(jsonTopics) {
      console.log("---- getTopics() ---");
      console.log(jsonTopics.getUser.name);

      let topicsTree = [];
      if (!jsonTopics) {
        topicsTree = [
          {
            id: "a",
            label: "a",
            children: [
              {
                id: "aa",
                label: "aa",
              },
              {
                id: "ab",
                label: "ab",
              },
            ],
          },
          {
            id: "b",
            label: "b",
          },
          {
            id: "c",
            label: "c",
          },
        ];
      } else {
        buildTopicsTree(topicsTree, jsonTopics.getUser.rootTopics, false);
        
        let childrenArr = [];
        buildTopicsTree(childrenArr, jsonTopics.getUser.rootTopics, true);

        // Mind Map
        let mindMap = {
            el: "#map",
            direction: MindElixir.SIDE,
            data: { nodeData: { id: 'root',
                    topic: 'Knowledge Graph',
                    root: true,
                    children: childrenArr } },
            draggable: true, // default true
            contextMenu: true, // default true
            toolBar: true, // default true
            nodeMenu: true, // default true
            keypress: true, // default true
          };

        this.ME = new MindElixir(mindMap);
        this.ME.init();
        // console.log(this.ME.getAllData());

        this.topics = topicsTree;
        return jsonTopics;
      }
    },
  },
  data() {
    return {
      getUser: "",
      selectedUser: "",
      prevSelectedUser: "",
      newUser: "",
      openOnClick: true,
      topics: [],
      ME: null,
    };
  },
  mounted() {
    this.ME = new MindElixir(meData);
    this.ME.init();
  },
};
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
}
</style>
