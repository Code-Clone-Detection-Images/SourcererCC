-- created from a dump of the vm-sql database
USE oopslaDB;

DROP TABLE IF EXISTS `files`;

CREATE TABLE `files` (
  `fileId` bigint(6) unsigned NOT NULL AUTO_INCREMENT,
  `projectId` int(8) unsigned NOT NULL,
  `relativePath` varchar(4000) DEFAULT NULL,
  `relativeUrl` varchar(4000) DEFAULT NULL,
  `fileHash` char(32) NOT NULL,
  PRIMARY KEY (`fileId`),
  KEY `projectId` (`projectId`),
  KEY `fileHash` (`fileHash`)
) ENGINE=MyISAM AUTO_INCREMENT=50038474 DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `projectId` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `projectPath` varchar(4000) DEFAULT NULL,
  `projectUrl` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`projectId`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `stats`;
CREATE TABLE `stats` (
  `fileHash` char(32) NOT NULL,
  `fileBytes` int(6) unsigned NOT NULL,
  `fileLines` int(6) unsigned NOT NULL,
  `fileLOC` int(6) unsigned NOT NULL,
  `fileSLOC` int(6) unsigned NOT NULL,
  `totalTokens` int(6) unsigned DEFAULT NULL,
  `uniqueTokens` int(6) unsigned DEFAULT NULL,
  `tokenHash` char(32) DEFAULT NULL,
  PRIMARY KEY (`fileHash`),
  KEY `tokenHash` (`tokenHash`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `CCPairs`;
CREATE TABLE `CCPairs` (
  `projectId1` int(8) NOT NULL,
  `fileId1` bigint(15) NOT NULL,
  `projectId2` int(8) NOT NULL,
  `fileId2` bigint(15) NOT NULL,
  PRIMARY KEY (`fileId1`,`fileId2`),
  KEY `projectId1` (`projectId1`),
  KEY `fileId1` (`fileId1`),
  KEY `projectId2` (`projectId2`),
  KEY `fileId2` (`fileId2`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;