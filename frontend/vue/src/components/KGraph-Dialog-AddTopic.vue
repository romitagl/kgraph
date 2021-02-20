<script>
export default {
  name: 'KGraphDialogAddTopic',
  data: function () {
    return {
      dialog: false,
      addTopicName: '',
      addTopicContent: '',
    }
  },
  // https://vuejs.org/v2/guide/components.html#Passing-Data-to-Child-Components-with-Props
  props: {
    clickFunction : {
      type: Function,
      required: true
    }
  }
}
</script>

<template>
  <v-row justify="center">
    <v-btn
      color="primary"
      text
      @click.stop="dialog = true; addTopicName = ''; addTopicContent = ''"
    >
      Add Child
    </v-btn>

    <v-dialog
      v-model="dialog"
      max-width="290"
    >
      <v-card>
        <v-card-title class="headline">
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
          <v-spacer></v-spacer>

          <v-btn
            color="primary"
            text
            @click="dialog = false"
          >
            Cancel
          </v-btn>

          <v-btn
            color="primary"
            text
            @click="clickFunction(true, addTopicName, addTopicContent); dialog = false"
          >
            Add
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-row>
</template>