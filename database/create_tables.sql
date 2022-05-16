/*
 *
 *  * Copyright (c) John Rodley 2022.
 *  * SPDX-FileCopyrightText:  John Rodley 2022.
 *  * SPDX-License-Identifier: MIT
 *  *
 *  * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 *  * software and associated documentation files (the "Software"), to deal in the
 *  * Software without restriction, including without limitation the rights to use, copy,
 *  * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 *  * and to permit persons to whom the Software is furnished to do so, subject to the
 *  * following conditions:
 *  *
 *  * The above copyright notice and this permission notice shall be included in all
 *  * copies or substantial portions of the Software.
 *  *
 *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *  * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 *  * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 *  * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 *  * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *  *
 *
 */

DROP TABLE IF EXISTS BuildableProject CASCADE;

CREATE TABLE BuildableProject
(
    BuildableProjectID              serial primary key,
    ProjectType                     varchar(255),
    Name                            varchar(255),
    SubprojectName                  varchar(255),
    URL                             varchar(255),
    Notes                           varchar(255),
    Category                        varchar(255),
    Stars                           varchar(255),
    Major                           varchar(255),
    Minor                           varchar(255),
    Patch                           varchar(255),
    LastCrawledDateTimeMilliseconds int
);

CREATE UNIQUE INDEX bpuniques on BuildableProject (ProjectType,Name,SubprojectName,URL,Major,Minor,Patch);

DROP TABLE IF EXISTS HardwarePlatform CASCADE;

CREATE TABLE HardwarePlatform
(
    HardwarePlatformID serial primary key,
    Manufacturer    varchar(255) not null,
    Board   varchar(255) not null,
    Major   int not null default 0,
    Minor   int not null default 0,
    Patch   int not null default 0
);
CREATE UNIQUE INDEX hardwareuniques on HardwarePlatform (Manufacturer,Board,Major,Minor,Patch);

DROP TABLE IF EXISTS OperatingSystem CASCADE;

CREATE TABLE OperatingSystem (
                                 OperatingSystemID serial primary key,
                                 PrettyName  varchar(255) not null default '',
                                 DistroLongName  varchar(255) not null,
                                 CodeName    varchar(255) not null default '',
                                 DistroName    varchar(255) not null,
                                 Major   int not null default 0,
                                 Minor   int not null default 0,
                                 Patch   int not null default 0
);
CREATE UNIQUE INDEX osuniques on OperatingSystem (DistroName,Major,Minor,Patch);

DROP TABLE IF EXISTS Platform CASCADE;

CREATE TABLE Platform
(
    PlatformID         serial primary key,
    HardwarePlatformID int not null,
    OperatingSystemID  int not null,
    FOREIGN KEY (HardwarePlatformID) REFERENCES HardwarePlatform (HardwarePlatformID),
    FOREIGN KEY (OperatingSystemID) REFERENCES OperatingSystem (OperatingSystemID)
);
CREATE UNIQUE INDEX platformuniques on Platform (HardwarePlatformID,OperatingSystemID);

DROP TABLE IF EXISTS IcebreakerVersion CASCADE;

CREATE TABLE IcebreakerVersion
(
    IcebreakerVersionID serial primary key,
    Major int not null,
    Minor int not null,
    Patch int not null,
    Build bigint not null,
    CreatedDateTime timestamp with time zone not null default current_timestamp
);

DROP TABLE IF EXISTS TestRun CASCADE;

CREATE TABLE TestRun
(
    TestRunID              serial primary key,
    BuildableProjectID              int not null,
    PlatformID int not null,
    IcebreakerVersionID int not null,
    Result varchar(255),
    TestRunStartDateTimeMilliseconds int,
    TestRunEndDateTimeMilliseconds int,
    FailedOnStage varchar(255),
    StageFailureMessage varchar(1024),
    FOREIGN KEY (IcebreakerVersionID) REFERENCES IcebreakerVersion (IcebreakerVersionID),
    FOREIGN KEY (BuildableProjectID) REFERENCES BuildableProject (BuildableProjectID),
    FOREIGN KEY (PlatformID) REFERENCES Platform (PlatformID)
);

