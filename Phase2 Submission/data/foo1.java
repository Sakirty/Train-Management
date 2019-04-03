import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;
//this is for route changes, add the station #
public class foo1{
    static ArrayList<Integer> all = new ArrayList<Integer>(); 
    static String[][] allinput = new String[1000][];
    static String[][] stations = new String[1000][];
    static String[][] stops = new String[1000][];
    static int allindex = 0;
    public static void main(String args[]) throws FileNotFoundException{
        File file = new File("./Routes.txt");
        Scanner sc = new Scanner(file);
        String s;
        while(sc.hasNextLine()){
            s = sc.nextLine();
            String r1=s.replace("Route: ","");
            String r2=r1.replace(" Stations: ",";");
            String r3=r2.replace(" Stops: ",";");
            allinput[allindex]=r3.split(";");
            allindex++;
        }
        for(int i = 0; i < allindex; i++)
        {
            stations[i] = allinput[i][1].split(", ");
            stops[i] = allinput[i][2].split(", ");
        }
        sc.close();
        try {
                    PrintStream out = new PrintStream(new FileOutputStream("route_and_stations.txt"));
                    for (int i = 0; i < allindex; i++)
                    {
                        List<String> list = Arrays.asList(stops[i]);
                        for (int j = 0; j < stations[i].length; j++)
                        {
                            out.print(allinput[i][0]+ "," + stations[i][j]);
                            if(list.contains(stations[i][j])) out.println(",true");
                            else out.println(",false");
                        }
                    }
                    out.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
        System.exit(0);
    }
}