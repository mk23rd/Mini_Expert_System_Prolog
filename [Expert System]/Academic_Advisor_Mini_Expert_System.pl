% Knowledge Base

:- dynamic course/3.  % Declare course/3 as dynamic to allow runtime modifications
:- dynamic student/5.  % Declare student/5 as dynamic to allow runtime modifications
:- dynamic completed/2.  % Declare completed/2 as dynamic to allow runtime modifications
:- dynamic performance/3.  % Declare performance/3 as dynamic to allow runtime modifications

% Define courses with course ID, name, and credit value.
course(cs101, 'Introduction to Computer Science', 4).
course(cs102, 'Data Structures', 4).
course(cs103, 'Algorithms', 4).
course(math101, 'Calculus I', 3).
course(math102, 'Calculus II', 3).

% Define prerequisites for each course.
prerequisite(cs102, cs101).
prerequisite(cs103, cs102).
prerequisite(math102, math101).

% Define major requirements for each major.
major(cs, cs101).
major(cs, cs102).
major(cs, cs103).
major(math, math101).
major(math, math102).

% Define minimum passing grade
passing_grade(50).

% Student database to store student information.
% student(StudentID, Name, Batch, Department, Major).
:- dynamic student/5.  % Declare student/5 as a dynamic predicate to allow runtime modifications

% Track courses that a student has completed.
% completed(StudentID, Course).
:- dynamic completed/2.  % Declare completed/2 as a dynamic predicate to allow runtime modifications

% Inference Engine

% Determine if a student can take a particular course.
% Check if a student can take a particular course.
% can_take(StudentID, Course).
can_take(StudentID, Course) :-
    course(Course, _, _),  % Ensure the course exists.
    student(StudentID, _, _, _, Major),  % Get student's major.
    major(Major, Course),  % Check if the course is required for the student's major.
    \+ completed(StudentID, Course),  % Ensure the course isn't already completed.
    \+ has_unmet_prereq(StudentID, Course).  % Ensure prerequisites are met.

% Check for unmet prerequisites.
% has_unmet_prereq(StudentID, Course).
has_unmet_prereq(StudentID, Course) :-
    prerequisite(Course, Prereq),  % Find the prerequisite course.
    \+ completed(StudentID, Prereq).  % Check if the prerequisite is unmet.

% Check if the course is required for the student's major.
% meets_major_requirements(StudentID, Course).
meets_major_requirements(StudentID, Course) :-
    student(StudentID, _, _, _, Major),  % Retrieve the student's major.
    major(Major, Course).  % Check if the course is required for the major.

% Check if the student’s grades are sufficient to take the next course.
% meets_grade_requirements(StudentID, Course).
meets_grade_requirements(StudentID, Course) :-
    ( \+ prerequisite(Course, _)  % No prerequisites, no grade check needed.
    ;  prerequisite(Course, Prereq),  % Find prerequisite course.
       performance(StudentID, Prereq, Grade),  % Retrieve the student's grade for the prerequisite.
       passing_grade(MinGrade),  % Retrieve the minimum passing grade.
       Grade >= MinGrade ).  % Ensure the grade meets the minimum passing criteria.

% Knowledge Acquisition

% Add a new course to the system dynamically.
% add_course.
add_course :-
    write('Enter Course ID: '), read(CourseID),  % Prompt for Course ID.
    write('Enter Course Name: '), read(CourseName),  % Prompt for Course Name.
    write('Enter Credits: '), read(Credits),  % Prompt for Credits.
    \+ course(CourseID, _, _),  % Ensure the course isn't already in the system.
    assertz(course(CourseID, CourseName, Credits)),  % Add the new course.
    format('Course ~w added successfully.~n', [CourseName]).  % Confirm course addition.

% Add student information.
% add_student.
add_student :-
    write('Enter Student ID: '), read(StudentID),  % Prompt for Student ID.
    write('Enter Student Name: '), read(Name),  % Prompt for Student Name.
    write('Enter Batch: '), read(Batch),  % Prompt for Batch.
    write('Enter Department: '), read(Department),  % Prompt for Department.
    write('Enter Major: '), read(Major),  % Prompt for Major.
    \+ student(StudentID, _, _, _, _),  % Ensure the student isn't already in the system.
    assertz(student(StudentID, Name, Batch, Department, Major)),  % Add the new student.
    format('Student ~w added successfully.~n', [StudentID]).  % Confirm student addition.

% Update student performance (grades) and mark the course as completed if passing.
% update_grade.
update_grade :-
    write('Enter Student ID: '), read(StudentID),  % Prompt for Student ID.
    write('Enter Course ID: '), read(CourseID),  % Prompt for Course ID.
    write('Enter Grade: '), read(Grade),  % Prompt for Grade.
    retractall(performance(StudentID, CourseID, _)),  % Remove any existing grade for the course.
    assertz(performance(StudentID, CourseID, Grade)),  % Add the new grade.
    passing_grade(MinGrade),
    (   Grade >= MinGrade  % Check if the grade meets or exceeds the minimum passing grade.
    ->  assertz(completed(StudentID, CourseID)),  % Mark the course as completed.
        format('Grade ~w for Course ~w updated and course marked as completed.~n', [Grade, CourseID])
    ;   format('Grade ~w for Course ~w updated but course not marked as completed.~n', [Grade, CourseID])
    ).

% Mark a course as completed for a student.
% mark_completed.
mark_completed :-
    write('Enter Student ID: '), read(StudentID),  % Prompt for Student ID.
    write('Enter Course ID: '), read(CourseID),  % Prompt for Course ID.
    (   student(StudentID, _, _, _, _)  % Check if the student exists.
    ->  assertz(completed(StudentID, CourseID)),  % Mark the course as completed.
        format('Course ~w marked as completed for student ~w.~n', [CourseID, StudentID])
    ;   format('Student ID ~w does not exist.~n', [StudentID])
    ).

% User Interface

% Provide a list of recommended courses based on major and performance.
recommend_courses :-
    write('Enter Student ID: '), 
    read(StudentID),  % Prompt for Student ID.
    
    (   student(StudentID, Name, _, _, _)  % Check if the student exists.
    ->  findall(Course, can_take(StudentID, Course), Courses),  % Find courses the student can take.
    
        (   Courses \= []  % Check if there are any recommended courses.
        ->  format('Recommended courses for ~w: ~w~n', [Name, Courses])  % List recommended courses.
        ;   true  % Do nothing if no courses are available.
        )
    ;   true  % Do nothing if the student does not exist.
    ).


% Explanation Module

% Explain why a course is recommended or not.
% explain_recommendation.
% Predicate to explain why a course is recommended or not.
explain_recommendation :-
    write('Enter Student ID: '), read(StudentID),  % Prompt for Student ID.
    student(StudentID, Name, _, _, _),  % Verify student exists.
    write('Enter Course ID: '), read(Course),  % Prompt for Course ID.
    (   can_take(StudentID, Course)  % Check if the student can take the course.
    ->  format('~w can take ~w because all prerequisites are met and it is required for their major.~n', [Name, Course])
    ;   findall(Prereq, (prerequisite(Course, Prereq), \+ completed(StudentID, Prereq)), UnmetPrereqs),  % Gather unmet prerequisites.
        (   UnmetPrereqs \= []  % Check if there are any unmet prerequisites.
        ->  format('~w cannot take ~w because the following prerequisites are not met: ~w~n', [Name, Course, UnmetPrereqs])
        ;   meets_major_requirements(StudentID, Course)  % Check if the course is already completed.
        ->  format('~w cannot take ~w because it is already completed.~n', [Name, Course])
        ;   format('~w cannot take ~w because it is not required for their major.~n', [Name, Course])
        )
    ).

% Check if a student has completed a course.
% course_completed(StudentID, Course).
course_completed(StudentID, Course) :-
    completed(StudentID, Course),  % Check if the course is marked as completed.
    format('Student ~w has completed course ~w.~n', [StudentID, Course]).  % Confirm completion.

% List all available courses.
list_courses :-
    write('Available Courses:~n'),  % Display a header for the list.
    forall(course(ID, Name, Credits),  % Iterate over all courses.
           format('Course ID: ~w, Name: ~w, Credits: ~w~n', [ID, Name, Credits])).  % Print course details.

% List all students.
list_students :-
    write('List of Students:~n'),  % Display a header for the list.
    forall(student(ID, Name, Batch, Department, Major),  % Iterate over all students.
           format('Student ID: ~w, Name: ~w, Batch: ~w, Department: ~w, Major: ~w~n', [ID, Name, Batch, Department, Major])).  % Print student details.

% List all completed courses for a given student.
list_completed_courses :-
    write('Enter Student ID: '),  % Prompt for Student ID.
    read(StudentID),  % Read the Student ID from user input.
    (   student(StudentID, Name, _, _, _)  % Check if the student exists.
    ->  findall(Course, completed(StudentID, Course), Courses),  % Find all completed courses.
        (   Courses \= []
        ->  format('Completed courses for student ~w: ~w~n', [Name, Courses])
        ;   format('No completed courses found for student ~w.~n', [Name])
        )
    ;   format('Student ID ~w does not exist.~n', [StudentID])
    ).
