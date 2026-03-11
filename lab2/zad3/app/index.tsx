import { supabase } from "@/utils/supabase";
import React from "react";
import { useEffect, useState } from "react";
import { Text, View } from "react-native";

export default function Index() {

  const [tasks, setTasks] = useState<any>([]);

  const fetchData = async () => {
    const { data, error } = await supabase.from('tasks').select('*');
    if (error) {
      console.error('Error fetching data:', error);
    } else {
      setTasks(data);
      console.log('Data fetched successfully:', data);
    }
  };

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <View>
      <Text>My Tasks</Text>
      {tasks.map((task: any) => (
        <View key={task.id}>
          <Text>{task.title}</Text>
          <Text>{task.description}</Text>
        </View>
      ))}

    </View>
  );
}