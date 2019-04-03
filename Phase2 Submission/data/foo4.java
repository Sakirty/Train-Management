import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;
public class foo4{
    static String[] allinput = new String[1000];
    static int allindex = 0;
    public static void main(String args[]) throws FileNotFoundException{
        File file = new File("./RAIL_LINES_new.txt");
        Scanner sc = new Scanner(file);
        String s;
        while(sc.hasNextLine()){
            s = sc.nextLine();
            String[] parts = s.split(";");
            String tempStr = "";
            String[] partB = parts[1].split(", ");
            String[] partC = parts[2].split(", ");
            //System.out.println(parts[0]+"-----"+parts[1] +"-----"+parts[2]);
            int i = 0;
            while(i < partB.length){
                tempStr = parts[0];
                if(i==0){
                    tempStr = tempStr + ";" + partB[i] + ";" + partB[i] + ";" + partC[i];
                }else{
                    tempStr = tempStr + ";" + partB[i-1] + ";" +partB[i] + ";" + partC[i];
                }
                allinput[allindex]=tempStr;
                allindex++;
                i++;
            }
        }
        sc.close();
        try {
                    PrintStream out = new PrintStream(new FileOutputStream("Distances.txt"));
                    for (int i = 0; i < allindex; i++)
                        out.println(allinput[i]);
                    out.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
        System.exit(0);
    }
}