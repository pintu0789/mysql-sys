/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */

/*
 * View: memory_by_user_by_current_bytes
 *
 * Summarizes memory use by user using the 5.7 Performance Schema instrumentation.
 *
 * mysql> select * from memory_by_user_by_current_bytes WHERE user IS NOT NULL;
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | user | current_count_used | current_allocated | current_avg_alloc | current_max_alloc | total_allocated |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | root |               1401 | 1.09 MiB          | 815 bytes         | 334.97 KiB        | 42.73 MiB       |
 * | mark |                201 | 496.08 KiB        | 2.47 KiB          | 334.97 KiB        | 5.50 MiB        |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW memory_by_user_by_current_bytes (
  user,
  current_count_used,
  current_allocated,
  current_avg_alloc,
  current_max_alloc,
  total_allocated
) AS
SELECT user,
       SUM(current_count_used) AS current_count_used,
       sys.format_bytes(SUM(current_number_of_bytes_used)) AS current_allocated,
       sys.format_bytes(SUM(current_number_of_bytes_used) / SUM(current_count_used)) AS current_avg_alloc,
       sys.format_bytes(MAX(current_number_of_bytes_used)) AS current_max_alloc,
       sys.format_bytes(SUM(sum_number_of_bytes_alloc)) AS total_allocated
  FROM performance_schema.memory_summary_by_user_by_event_name
 GROUP BY user
 ORDER BY SUM(current_number_of_bytes_used) DESC;

/*
 * View: x$memory_by_user_by_current_bytes
 *
 * Summarizes memory use by user
 *
 * mysql> select * from x$memory_by_user_by_current_bytes WHERE user IS NOT NULL;
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | user | current_count_used | current_allocated | current_avg_alloc | current_max_alloc | total_allocated |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | root |               1399 |           1124553 |          803.8263 |            343008 |        45426133 |
 * | mark |                201 |            507990 |         2527.3134 |            343008 |         5769804 |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW x$memory_by_user_by_current_bytes (
  user,
  current_count_used,
  current_allocated,
  current_avg_alloc,
  current_max_alloc,
  total_allocated
) AS
SELECT user,
       SUM(current_count_used) AS current_count_used,
       SUM(current_number_of_bytes_used) AS current_allocated,
       SUM(current_number_of_bytes_used) / SUM(current_count_used) AS current_avg_alloc,
       MAX(current_number_of_bytes_used) AS current_max_alloc,
       SUM(sum_number_of_bytes_alloc) AS total_allocated
  FROM performance_schema.memory_summary_by_user_by_event_name
 GROUP BY user
 ORDER BY SUM(current_number_of_bytes_used) DESC;
