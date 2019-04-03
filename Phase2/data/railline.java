import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;
public class railline{
    static String[][] allinput = new String[1000][];
    static int allindex = 0;
    public static void main(String args[]) throws FileNotFoundException{
        File file = new File("./RailLines.txt");
        Scanner sc = new Scanner(file);
        String s;
        while(sc.hasNextLine()){
            s = sc.nextLine();
            String r1=s.replace("Line ID: ","");
            String r2=r1.replace(" Speed Limit: ",";");
            String r3=r2.replace(" Stations: ",";");
            allinput[allindex]=r3.split(";");
            allindex++;
        }
        sc.close();
        try {
                    PrintStream out = new PrintStream(new FileOutputStream("railline_and_speedlimit.txt"));
                    for (int i = 0; i < allindex; i++)
                        out.println(allinput[i][0] + "," + allinput[i][1]);
                    out.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
        System.exit(0);
    }
}