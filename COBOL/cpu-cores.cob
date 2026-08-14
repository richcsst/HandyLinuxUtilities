IDENTIFICATION DIVISION.
       PROGRAM-ID. CPU-CORES.
       AUTHOR. RICHARD KELSCH.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OS-RELEASE-FILE ASSIGN TO "/etc/os-release"
                  ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CPUINFO-FILE ASSIGN TO "/proc/cpuinfo"
                  ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  OS-RELEASE-FILE.
       01  OS-LINE            PIC X(256).
       
       FD  CPUINFO-FILE.
       01  CPU-LINE           PIC X(256).

       WORKING-STORAGE SECTION.
       01  FLAGS-AND-COUNTERS.
           05  ARG-COUNT      BINARY-LONG.
           05  EOF-FLAG       PIC X VALUE "N".
               88  FINISHED-READING VALUE "Y".
       01  SYS-BUFFERS.
           05  OS-NAME        PIC X(50) VALUE "Linux".
           05  CPU-MODEL      PIC X(80) VALUE "Generic CPU".
       
       LINKAGE SECTION.
       01  COB-ARGS.
           05  LN-ARG-COUNT   BINARY-LONG.

       PROCEDURE DIVISION.
           ACCEPT ARG-COUNT FROM ARGUMENT-NUMBER
           
           IF ARG-COUNT > 0
               PERFORM GET-OS-NAME
               PERFORM GET-CPU-MODEL
               DISPLAY " "
               DISPLAY " OS:  " FUNCTION TRIM(OS-NAME)
               DISPLAY "CPU:  " FUNCTION TRIM(CPU-MODEL)
               DISPLAY " "
           ELSE
               *> No arguments: execute system 'nproc' via shell shortcut
               CALL "SYSTEM" USING "nproc"
           END-IF
           
           GOBACK.

       GET-OS-NAME.
           OPEN INPUT OS-RELEASE-FILE
           MOVE "N" TO EOF-FLAG
           PERFORM UNTIL FINISHED-READING
               READ OS-RELEASE-FILE
                   AT END MOVE "Y" TO EOF-FLAG
                   NOT AT END
                       IF OS-LINE(1:12) = "PRETTY_NAME="
                           *> Strip quotes and copy value
                           MOVE OS-LINE(14:50) TO OS-NAME
                           MOVE "Y" TO EOF-FLAG
                       END-IF
               END-READ
           END-PERFORM
           CLOSE OS-RELEASE-FILE.

       GET-CPU-MODEL.
           OPEN INPUT CPUINFO-FILE
           MOVE "N" TO EOF-FLAG
           PERFORM UNTIL FINISHED-READING
               READ CPUINFO-FILE
                   AT END MOVE "Y" TO EOF-FLAG
                   NOT AT END
                       IF CPU-LINE(1:10) = "model name"
                           *> Find the colon and extract the model
                           MOVE CPU-LINE(14:80) TO CPU-MODEL
                           MOVE "Y" TO EOF-FLAG
                       END-IF
               END-READ
           END-PERFORM
           CLOSE CPUINFO-FILE.

