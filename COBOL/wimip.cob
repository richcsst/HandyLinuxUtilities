IDENTIFICATION DIVISION.
       PROGRAM-ID. WIMIP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TMP-JSON ASSIGN TO "api.tmp"
                  ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  TMP-JSON.
       01  JSON-LINE          PIC X(1000).

       WORKING-STORAGE SECTION.
       01  CMD-STRING         PIC X(200).
       01  API-KEY            PIC X(50).
       01  IP-ADDRESS         PIC X(40).
       01  STR-POS            BINARY-LONG.
       01  END-POS            BINARY-LONG.

       PROCEDURE DIVISION.
           ACCEPT API-KEY FROM ARGUMENT-VALUE
           IF API-KEY = SPACES
               DISPLAY "Missing key" UPON SYSERR
               STOP RUN RETURNING 1
           END-IF

           *> Fetch IP address via curl
           STRING "curl -s 'https://wimi-api.whatismyip.com/ip?key=" 
                  FUNCTION TRIM(API-KEY) "' > api.tmp" 
                  DELIMITED BY SIZE INTO CMD-STRING
           CALL "SYSTEM" USING CMD-STRING

           *> Parse IP Address out of JSON manually
           OPEN INPUT TMP-JSON
           READ TMP-JSON
           CLOSE TMP-JSON
           
           UNSTRING JSON-LINE DELIMITED BY '"ip":"' 
               INTO CMD-STRING IP-ADDRESS
           
           INSPECT IP-ADDRESS TALLYING STR-POS FOR CHARACTERS 
               BEFORE INITIAL '"'
           MOVE IP-ADDRESS(1:STR-POS) TO IP-ADDRESS

           *> Fetch Info metadata via curl
           MOVE SPACES TO CMD-STRING
           STRING "curl -s 'https://wimi-api.whatismyip.com/"
                  "ip-address-lookup/" FUNCTION TRIM(IP-ADDRESS)
                  "?key=" FUNCTION TRIM(API-KEY) "' > api.tmp"
                  DELIMITED BY SIZE INTO CMD-STRING
           CALL "SYSTEM" USING CMD-STRING

           *> Read the metadata file and print it out
           OPEN INPUT TMP-JSON
           READ TMP-JSON
           CLOSE TMP-JSON

           *> For demonstration: print out the final payload file
           DISPLAY "export WHATISMYIP_IP=""" FUNCTION TRIM(IP-ADDRESS) """"
           
           CALL "SYSTEM" USING "rm -f api.tmp"
           GOBACK.

