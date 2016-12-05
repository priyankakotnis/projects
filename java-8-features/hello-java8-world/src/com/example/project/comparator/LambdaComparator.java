package com.example.project.comparator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 *
 * @author Priyanka Kotnis
 */
public class LambdaComparator {
    
    public static void main(String[] args) {
        
        List<String> myMovies = new ArrayList<String>();
        myMovies.add("AMIR");
        myMovies.add("baazigaar");
        myMovies.add("CAT");
        myMovies.add("dhoom");
        myMovies.add("EROS");
        myMovies.add("fantush");
        myMovies.add("GOLMAAL");
        
        Collections.sort(myMovies);
        System.out.println("Sorted:");
        for (String movie : myMovies) {
            System.out.println(movie);
        }
        
        //Lambda Comparator
        Comparator<String> noCase = (str1, str2) -> {
            return str1.compareToIgnoreCase(str2);
        };
        
        Collections.sort(myMovies, noCase);
        System.out.println("Sorted ignoring case:");
        for (String movie : myMovies) {
            System.out.println(movie);
        }
        
        System.out.println("Now traversing using Lambda..");
        //Lambda traversal
        myMovies.forEach(movie -> System.out.println(movie));
    }
    
}
