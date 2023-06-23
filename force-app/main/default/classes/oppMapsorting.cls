public class oppMapsorting {
    public static void mymethod(){
        List<Opportunity> oppty = [SELECT Id, OwnerId, StageName, Name FROM Opportunity];
map<Id, Integer> oppty_map = new map<Id, Integer>();

for(Opportunity o : oppty){
    if(oppty_map.containsKey(o.OwnerId)){
        oppty_map.put(o.OwnerId, oppty_map.get(o.OwnerId) + 1);    
    }else{
        oppty_map.put(o.OwnerId, 1);
    }
}

//create a map with key as ownerId and value as the count 
System.debug(' 🚀 ' +oppty_map);

List<Integer> i_values = oppty_map.values();
i_values.sort();

//get the max value of the count
Integer i_max_value = i_values[(i_values.size()-1)];

for(String s : oppty_map.keySet()){
    Integer oppty_map_value = oppty_map.get(s);

    if(oppty_map_value == i_max_value){
        System.debug(' Id is ' + s + ' value is ' + oppty_map_value);
    }

}
    }

}