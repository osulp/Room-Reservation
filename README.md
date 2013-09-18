Valley Library Room Reservation System
============================

This repository contains the source code for the Room Reservation system which will be in use at the Oregon State
University Libraries & Press' Valley Library.

Status
----------------------------
This application is in active development and not ready for use in production.

Usage Outside OSU L&P
----------------------------
Currently this system relies upon a variety of systems only in use at OSU's Valley Library. The assumptions made
are as follows:

* There is an external database containing information regarding when the library is open.
* Logins are managed via a CAS (Central Authentication Service.)
* There is extra information regarding users stored in an external database, which can be accessed via their username.
  *  This database stores encrypted student ID numbers.

Work towards generalizing these assumptions may be done at a later date. Pull requests accepted.

Caching
----------------------------
This application makes heavy use of caching via memcached for available times. However, it should be fast enough
without the caching for general use. Implementing caching requires the following:

* Memcached running locally
* A database server which supports sub-second timestamps.
  * Required to avoid race conditions in which two records are updated at the same time.
  * Currently we use MariaDB 5.5 for this. Postgresql should also work.