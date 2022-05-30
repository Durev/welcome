# Backend test

Here is my solution proposition for the 2 exercices of the test.

In this README, you will find the install guide for ex01 and links to the documens containing the explanations for the choices and thinking behind both exercices.

## Ex01

### Installation

#### Install Ruby

Make sure the `3.0.4` version of Ruby is installed on your system.

- with rbenv
  `rbenv install 3.0.4`

- with rvm
  `rvm install 3.0.4`

#### Install bundler gem

```bash
gem install bundler
```

#### Move into the ex01 directory

```bash
cd ex01/
```

#### Install depencies for this application

```bash
bundle install
```

#### Setup the database

Create the database and its schema:

```bash
bundle exec rake db:create
bundle exec rake db:migrate
```



You're all set! 🚀



### Usage

#### Load input data

The application uses a SQLite relational database. The first step is to import records, from the input CSV, to the app database.

The exercice input files for jobs and professions have been put in the `db/data` directory.

They can be imported in the database, respectively using:

```bash
bundle exec rake data:load_professions
bundle exec rake data:load_job_offers
```



**Alternative: custom files**

You can also load different data than the one initially given with the exercice, by passing the filepath as an argument to the tasks:

```bash
bundle exec rake data:load_professions db/data/professions.csv
bundle exec rake data:load_job_offers db/data/jobs.csv
```

Just bare in mind that there is no specific error management or check on the input files here, so the task will crash loudly if the file format differs from the initial ones.



Il you need to start from a fresh dataset, drop the existing database and recreate the schema from scratch:

```bash
bundle exec rake db:drop && bundle exec rake db:create && bundle exec rake db:migrate
```



#### Reverse geocoding

`TODO: Improve step`



#### Print results

Once the data has been imported and reverse geocoded, we can easily print the count of offers per category and per continent

```bash
bundle exec rake results:print
=>
+---------------+----------+---------+------+-------------------+-------+--------+------+
|               | Business | Conseil | Créa | Marketing / Comm' | Admin | Retail | Tech |
+---------------+----------+---------+------+-------------------+-------+--------+------+
|               | 10       | 0       | 0    | 6                 | 4     | 8      | 8    |
| Africa        | 3        | 0       | 0    | 1                 | 1     | 1      | 3    |
| Asia          | 30       | 0       | 0    | 3                 | 1     | 6      | 11   |
| Europe        | 1371     | 175     | 205  | 759               | 396   | 426    | 1402 |
| North America | 27       | 0       | 7    | 12                | 9     | 93     | 14   |
| Oceania       | 0        | 0       | 0    | 1                 | 0     | 2      | 0    |
| South America | 4        | 0       | 0    | 0                 | 0     | 0      | 1    |
+---------------+----------+---------+------+-------------------+-------+--------+------+
```



### Explanations

Detailed explanations for the design choices of this application can be found there: [ex01/explanations.md](https://github.com/Durev/welcome/blob/main/ex01/explanations.md).



## Ex02

The solution for exercice 2 can be found there: [ex02/scaling.md](https://github.com/Durev/welcome/blob/main/ex02/scaling.md).
