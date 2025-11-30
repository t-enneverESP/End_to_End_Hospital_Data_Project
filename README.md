# End_to_End_Hospital_Data_Project
My first attempt at an end-to-end data project.
Working with data using Linux, PostreSQL and Power BI. An end-to-end project. For the first part of this process, a Linux RedHat/Fedora distribution was used, in a VM which I built on OracleBox. Full OS specifications in (screenshot 1).

The first step was to install and initialise PostgreSQL via Linux command, which I did with the following commands:

#Best practice to update packages before installing any new applications
sudo dnf update -y

#to install PostgreSQL
sudo dnf install postgresql-server postgresql-contrib

#initialise a database
sudo postgresql-setup --initdb

#starting the service
sudo systemctl start postgresql

#add service to list of programs that start on boot
sudo systemctl enable postgresql

#running check
sudo systemctl status postgresql

With PostgreSQL set up, the next step was to create a user. I did this through the following commands:

#switch to postgresql superuser
sudo -i -u postgres

#start the postgres prompt
psql

#set password
\password

With Postgres installed, it was time to install the desktop application, with I did with these commands

sudo dnf install -y https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm

sudo dnf install -y pgadmin4-desktop

And finally, PGadmin is installed! Next I had to complete the initial configuration of PostgreSQL (screenshot 4,2). I set the configurations to the default localhost settings for this database and my purposes, but encountered this error - "ident authentication failed for user".

Admittedly, I needed the troubleshooting help of Gemini for this, and the fix was a helpful learning experience about command-line file edits and vim. The issue was with the configuration file pg_hba.conf, which I was able to modify using vim text editor in command terminal (Screenshot 5):

#stop postgresql
sudo systemctl stop postgresql

#gain sudo access to postgre file
sudo vi /var/lib/pgsql/data/pg_hba.conf

Line Type	Original Setting (Before Edit)	New Setting (After Edit)	Reason for Change
Unix Socket (local)	local all all peer	local all all md5	Enables password authentication for local client apps (like pgAdmin).
IPv4 Loopback (host)	host all all 127.0.0.1/32 ident	host all all 127.0.0.1/32 md5	Enables password authentication for connections via 127.0.0.1.
IPv6 Loopback (host)	host all all ::1/128 ident	host all all ::1/128 md5	Enables password authentication for connections via ::1 (IPv6 local).

#restart postgresql
sudo systemctl start postgresql

After applying the suggested changes, I tried once again to establish a server on PostgreSQL and this time, success! My Fictional_Hospital server is created. (screenshot 3, 6)

Now, time to create a database. For this, I used a set of open source CSVs from Coursera (to whom full credit is due), based on a fictional hospital database of patients, departments and treatments. I created the database in PGadmin using the regular wizard, and checked the underlying SQL, and all good to go (screenshot 7).

Although the SQL is provided by Coursera to form the database, for this project I will attempt to define the relational model of the database myself, creating the tables and mapping the relationships through primary and foreign keys.

I downloaded them from my Drive folder, and extracted the CSVs simply using the unzip command in terminal

I will form the database in PGadmin and also form its relational model there. First, lets establish the table for our hospital locations. I navigated the following path in PG Admin to do this:

fictional_hospital>imaginary_hospital>schemas>public>create table
(screenshot 8)

In the CSV, we are given 3 columns, as seen in the screenshot (9). We I defined them as follows (screenshot 9): Location_ID and Dept_ID were defined as VARCHAR with a precise length of 4, to enforce ID format across tables for data integrity (L001, L002, D001, D002 Etc to infinity), whilst location name was defined as a simple VARCHAR 
with a limit of 25 characters. Location_ID will act as the primary key in this table, enforcing the uniqueness of each location, it is also a bridging table. Dept_ID will become a foreign key, but we can not define it as such in a relational database until the counterpart reference table (Departments) is created.

There are different ways to create tables on PGadmin, as on any SQL server. Whereas the first locations table was created via the interface, I created the Departments table directly through SQL, using the following code:

CREATE TABLE departments (
    dept_id VARCHAR(4) PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL #as departments may have longer name, I went with a 50-characted limit
);

With the locations and department tables created, it was time to establish a relationship between them, to achieve this, I used the PGadmin interface(screenshot 10-13)
and followed the steps, giving the relationship a descriptive name, and selecting the local and reference columns. 

Next, it was time to test the relationship. With my set up, every entry into Locations/Dept_ID should match a record in Departments/Dept_ID. To test this, I ran SQL attempting to insert a non-compliant row into locations. The result was a success! PGadmin returned an error message, reminding me of the constraints (Screenshot 14).

Since I have CSVs, I can also create tables with SQL, then upload the CSV To them. This is what I did with the "patients" table - a list of our fictional patients. I coded the "patients" table using this SQL statement (screenshot). Sex was set to Char(1) with a check-constraint so that only "M" or "F" could be inserted, phone number was represented as a VARCHAR as they would not be used for mathematical calculations, and dept_ID was referenced to the Dept_ID in the "departments table, as a foreign key. I believe these measures best ensure data integrity going forward. I am also in the habit of creating tables by starting with the DROP TABLE IF EXISTS command as a matter of best practise.

With the table up and running, I could now use the PGadmin wizard to upload a CSV into it. On the landing screen (screenshot 16-18), I set the encoding to UTF8, the "safe option" do to speak for this kind of task. After a quick check in the Options tab, to ensure that the comma is the delimiter and that the program understands that my Coursera CSV does not contain headers, I was ready to upload. And the upload was a success! I repeated this for the remaining tables - procedures and medical_history.

The medical history CSV was a bit unusual (screenshot 19). The last row stands out due to its encasing in commas, and there is a column where all entries start with I. After a bit of investigating I found out this is an ICD code, for billing and diagnoses. The row with a comma was to notify the RDBMS that whilst a comma is usually a delimiter, it should be ignored in that case and entered as a string. Finally, I settled on the following table (screenshot 20).

These tables were successfully populated using the provided CSVs, as before. With the database fully populates there's only one thing left to do. Back it up, of course. First, I created the shell script for it, using this syntax (screenshot21). When I checked my directory using ls -l, the file was there but without execute permissions, so I used the chmod command (screenshot 22) to change this - chmod +x backup.sh.I tested the backup file and it was a success (screenshot 23). Next, I made sure that it would automate at midnight every night using the following commands:
crontab -e
0 2 * * * /home/travbanks/backup.sh

I came across an error when initially trying to automate the backup, because the pg_dump command requires a password, and it can not be put in by the Cron scheduler. To work round this, I created a .pgpass file in my home directory, and put this single line in this structure:

localhost:5432:imaginary_hospital:postgres:PASSWORD

I then took the critical step of securing the read and write permissions of this file with the following Syntax:

chmod 0600 /home/travbanks/.pgpass 

I do not want to burden my poor VM with forever's worth of backups, so I later went back to add the following to my shell script:

find "$BACKUP_DIR" -type f -mtime +7 -name '*.sql' -delete

This way, back-ups older than 7 days will be deleted.

The database is now ready to be ingested into Fabric. I did this by using a SELECT * statement on each table, and downloading it to CSV. Right click > View Data could also be used on such a small dataset, but I consider the SELECT statement use better scalable practise.

I already have a LakeHouse and Warehouse running on Fabric from previous ventures, so I loaded them in (screenshot26). Once the files were uploaded I followed the interface to turn each one into a Delta table (screenshot27)

With the files now in Fabric as Delta tables, I can query them via Spark SQL(28a, 28b)

To work with the data in Power BI, we have to first follow the interface to create a semantic model (29). This takes us to a model view where we can once again model our diagram through an ERD creator (31). Lets begin!

First, lets drag patients:patient_id over to medical_history:patient_id and create a one-many relationship, and do similar to create one-to-many relationships between depts and medical_history, depts and medical_procedures, and depts and locations etc until the final star schema looks like so (32). I also changed the telephone number data type to text, as Fabric had read it as a number to sum.

With the relationships set, lets visualise! We can click file, and select create new report (33) and Power BI opens in a new tab! (34). Although there is not much data to work with in such a small set (I have my first ever dashboard on GitHub and will be diving deeper into Power Bi visuals in the coming week!) I was able to generate a simple dashboard nonetheless (final screenshot), therefore completing my end-to-end project. 

There are of course much quicker ways to take Coursera´s CSV files through a journey, but the learning process and troubleshooting experience has done me well in my first ever end-to-end project. Within the next few months I intend to complete more projects as well as sitting my PL-300 and DP-700 exams. Thanks to Coursera for providing the initial CSVs, to Gemini for troubleshooting early on, and to the resources I learned from that made this possible (IBM Data Engineering Professional Certificate, Sam´s Teach Yourself SQL by Ben Forta, The Linux Commabs Line by William Shotts). 
