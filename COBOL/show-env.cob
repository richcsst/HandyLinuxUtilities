IDENTIFICATION DIVISION.
       PROGRAM-ID. SHOW-ENV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ENV-FILE ASSIGN TO "env.tmp"
                  ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ENV-FILE.
       01  ENV-LINE           PIC X(500).

       WORKING-STORAGE SECTION.
       01  EOF-FLAG           PIC X VALUE "N".
           88  FINISHED-READING VALUE "Y".
       01  PARSING-STUFF.
           05  EQ-POS         BINARY-LONG.
           05  ENV-KEY        PIC X(30).
           05  ENV-VAL        PIC X(470).
       01  ANSI-ESCAPES.
           05  ESC            PIC X VALUE X"1B".
           05  HEADER-COLOR   PIC X(10) VALUE "[93;44m".
           05  KEY-COLOR      PIC X(10) VALUE "[1;33;41m".
           05  RESET-COLOR    PIC X(4)  VALUE "[0m".

       PROCEDURE DIVISION.
           *> Dump environment variables to a sorted temp file
           CALL "SYSTEM" USING "env | sort > env.tmp"
           
           DISPLAY " "
           DISPLAY ESC HEADER-COLOR "  Environment Variables" ESC RESET-COLOR
           
           OPEN INPUT ENV-FILE
           PERFORM UNTIL FINISHED-READING
               READ ENV-FILE
                   AT END MOVE "Y" TO EOF-FLAG
                   NOT AT END
                       PERFORM PROCESS-LINE
               END-READ
           END-PERFORM
           CLOSE ENV-FILE
           
           *> Cleanup temp file
           CALL "SYSTEM" USING "rm -f env.tmp"
           GOBACK.

       PROCESS-LINE.
           MOVE SPACES TO ENV-KEY ENV-VAL
           INSPECT ENV-LINE TALLYING EQ-POS FOR CHARACTERS 
               BEFORE INITIAL "="
           
           IF EQ-POS > 0 AND EQ-POS < 30
               MOVE ENV-LINE(1:EQ-POS) TO ENV-KEY
               ADD 2 TO EQ-POS
               MOVE ENV-LINE(EQ-POS:) TO ENV-VAL
               
               *> Print raw colorized block line
               DISPLAY ESC KEY-COLOR " " ENV-KEY " " ESC RESET-COLOR 
                       " = " FUNCTION TRIM(ENV-VAL)
           END-IF
           MOVE 0 TO EQ-POS.

