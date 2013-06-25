MdlSql
======

Modular Sql (queries)

Modular Sql is a modular query builder that enables a high database compatibility, usage 
easiness and dynamic construction. It is intended to allow any kind of query in any database,
but will, at the moment, only handle relatively simple ones to most common databases.

This api was initially intended for Bionline (http://bion-line.com).
 
Output is given as a MysqlResult object, more info @ https://github.com/brianmario/mysql2usage

@author Sebastián (Sikian) Neira Farriol, <sikian@gmail.com>
@version 0.1

@example Simple select
 	result = Array.new
 	result = MdlSql::select.from(:users).where(:id, 1, '=').execute

@example Simple insert
  	result = MdlSql::insert.into(:users).cols(:user, :role).values('admin',2).execute
