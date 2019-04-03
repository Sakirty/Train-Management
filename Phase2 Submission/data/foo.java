import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;
public class foo{
    static String[] allinput = new String[10000];
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
            String[] parts = r3.split(";"); 
            allinput[allindex]=parts[0];
            allindex++;
        }
        sc.close();
        try {
                    PrintStream out = new PrintStream(new FileOutputStream("RoutesOnly.txt"));
                    for (int i = 0; i < allindex; i++)
                        out.println(allinput[i]);
                    out.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
        System.exit(0);
    }
}