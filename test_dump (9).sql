-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Окт 14 2013 г., 12:57
-- Версия сервера: 5.5.25
-- Версия PHP: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `test_dump`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_linkset`(id_user int)
BEGIN
START TRANSACTION;
INSERT INTO linkset(user_id) VALUE (id_user);
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_message`(IN `text_message` TEXT, IN `url` VARCHAR(255), OUT `id` INT)
BEGIN
	INSERT INTO message (message_text, message_url) VALUES (text_message, url);
        SELECT COUNT(message_id) INTO id FROM message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_messageset`(IN `title` VARCHAR(255), IN `description` VARCHAR(255), OUT `rez` INT)
BEGIN
	
        DECLARE k int;
        START TRANSACTION;
        CALL create_userset(k);
        INSERT INTO messageset (messageset_title, messageset_discription, userset_id) VALUES (title, description, k);
	COMMIT;
        SELECT MAX(messageset_id) INTO rez FROM messageset;
	
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_tagset`(OUT `id_tagset` INT)
BEGIN
	INSERT INTO tagset(tagset_id) VALUES ('');
        SELECT MAX(tagset_id) INTO id_tagset FROM tagset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_userset`(OUT `us` INT)
BEGIN
INSERT INTO userset(userset_id) value ('');
SELECT MAX(userset_id) INTO us FROM userset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_message_messageset`(IN `text_message` TEXT, IN `url` VARCHAR(255), IN `id_messageset` INT, IN `id_user` INT)
BEGIN
	DECLARE q int;
        START TRANSACTION;
        CALL create_message(text_message, url, q);
        INSERT INTO message_messageset (message_id, messageset_id, user_id) VALUES (q, id_messageset, id_user);
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_paper`(IN `url` TEXT, IN `title` TEXT, IN `abstract` TEXT, IN `bibliography` TEXT, IN `status` INT, IN `description` VARCHAR(255), IN `users` VARCHAR(255), IN `tags` VARCHAR(255))
BEGIN
	DECLARE k, t int;
        START TRANSACTION;
        CALL create_userset(k);
        CALL create_tagset(t);
        CALL insert_user_userset(users, k);
        CALL insert_tagsub_tagset(tags, t);
	INSERT INTO paper(paper_uploaded_file_url, paper_title, paper_abstract, paper_bibliography, paper_status_map_id, paper_description, userset_id, tagset_id) VALUES (url, title, abstract, bibliography, status, description, k, t);
	

	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_paperset`(title varchar(255), status_paperset int, imprint varchar(255), description varchar(255), users varchar(255))
BEGIN
	DECLARE k int;
        DECLARE l int;
        START TRANSACTION;
        CALL create_userset(k);
        CALL insert_user_userset(users, k);
        CALL create_messageset('ком', 'Комментарии', l);
	INSERT INTO paperset(paperset_title, paperset_status_map_id, paperset_imprint, paperset_description, userset_id, messageset_id) VALUES (title, status_paperset, imprint, description, k, l);
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_paper_paperset`(id_paper int, id_paperset int, position_begin varchar(255), position_end varchar(255), users_expert varchar(255))
BEGIN
	DECLARE us2, ms1, ms2 int;
        START TRANSACTION;
        CALL create_messageset('эксп', 'экспертиза', ms1);
        CALL create_messageset('эксп', 'комментарии', ms2);

	CALL create_userset(us2);
        CALL insert_user_userset(users_expert, us2); 
        
        INSERT INTO paper_paperset(paper_id, paperset_id, userset_id, messageset_id, messageset_com_id, paper_position_begin, paper_position_end) VALUES (id_paper, id_paperset, us2, ms1, ms2, position_begin, position_end);
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_tagsub_tagset`(IN `mylist` VARCHAR(255), IN `id_tagset` INT)
body:
BEGIN
 
IF mylist = '' THEN LEAVE body; END IF;
  START TRANSACTION;
  SET @saTail = mylist;
  WHILE @saTail != '' DO
    SET @saHead = SUBSTRING_INDEX(@saTail, ',', 1);    
    SET @i=LENGTH(@saHead)+1;
    SET @saTail = SUBSTRING( @saTail, @i+1 );
    INSERT INTO `tagsub_tagset` (`tagsub_id`,`tagset_id`) VALUES (@saHead, id_tagset);
  END WHILE;
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_user`(IN `name` VARCHAR(255), IN `surname` VARCHAR(255), IN `patronymic` VARCHAR(255), IN `rdate` VARCHAR(255), IN `residence` VARCHAR(255), IN `gender` VARCHAR(10), IN `education` VARCHAR(255), IN `tags` VARCHAR(255), OUT `id_user` INT)
BEGIN
DECLARE t int;
START TRANSACTION;
CALL create_tagset(t);
CALL insert_tagsub_tagset(tags, t);
INSERT INTO user (user_name, user_surname, user_patronymic, user_date, user_residence, user_gender, user_education, tagset_id) VALUE (name, surname, patronymic, rdate, residence, gender, education, t);
SELECT MAX(user_id) INTO id_user FROM user;
CALL create_linkset(id_user);
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_user_userset`(IN `mylist` VARCHAR(255), IN `id_userset` INT)
body:
BEGIN
START TRANSACTION; 
IF mylist = '' THEN LEAVE body; END IF;
  
  SET @saTail = mylist;
  WHILE @saTail != '' DO
    SET @saHead = SUBSTRING_INDEX(@saTail, ',', 1);
    SET @us = SUBSTRING_INDEX(@saHead, '.', 1);
    SET @st = SUBSTRING_INDEX(@saHead, '.', -1);
        
    
    SET @i=LENGTH(@saHead)+1;
    SET @saTail = SUBSTRING( @saTail, @i+1 );
    SET @t=CAST(@us AS SIGNED);
    SET @y=CAST(@st AS SIGNED);
    INSERT INTO `user_userset` (`user_id`,`userset_id`, `user_userset_status_map_id`) VALUES (@t, id_userset, @y);
  END WHILE;
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_paper`(IN `url` TEXT, IN `title` TEXT, IN `abstract` TEXT, IN `bibliography` TEXT, IN `status` INT, IN `description` VARCHAR(255), IN `users` VARCHAR(255), IN `tags` VARCHAR(255), IN `id_paper` INT)
BEGIN
        DECLARE k, t int;
        START TRANSACTION;
        SET k=(SELECT userset_id FROM paper WHERE paper_id=id_paper);
        SET t=(SELECT tagset_id FROM paper WHERE paper_id=id_paper);
        CALL update_user_userset(users, k);
        CALL update_tagsub_tagset(tags, t);
        UPDATE paper SET paper_uploaded_file_url=url, paper_title=title, paper_abstract=abstract, paper_bibliography=bibliography, paper_status_map_id=status, paper_description=description WHERE paper_id=id_paper;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_paperset`(title varchar(255), status_paperset int, imprint varchar(255), description varchar(255), users varchar(255), id_paperset int)
BEGIN
	DECLARE k int;
        START TRANSACTION;
        SET k=(SELECT userset_id FROM paperset WHERE paperset_id=id_paperset);
        CALL update_user_userset(users, k);	
        UPDATE paperset SET paperset_title=title, paperset_status_map_id=status_paperset, paperset_imprint=imprint, paperset_description=description WHERE paperset_id=id_paperset;
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_tagsub_tagset`(IN `mylist` VARCHAR(255), IN `id_tagset` INT)
body:
BEGIN
START TRANSACTION;
DELETE FROM tagsub_tagset WHERE tagset_id=id_tagset; 
IF mylist = '' THEN LEAVE body; END IF;

  SET @saTail = mylist;
  WHILE @saTail != '' DO
    SET @saHead = SUBSTRING_INDEX(@saTail, ',', 1);    
    SET @i=LENGTH(@saHead)+1;
    SET @saTail = SUBSTRING( @saTail, @i+1 );
    INSERT INTO `tagsub_tagset` (`tagsub_id`,`tagset_id`) VALUES (@saHead, id_tagset);
  END WHILE;
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user`(IN `name` VARCHAR(255), IN `surname` VARCHAR(255), IN `patronymic` VARCHAR(255), IN `rdate` VARCHAR(255), IN `residence` VARCHAR(255), IN `gender` VARCHAR(10), IN `education` VARCHAR(255), IN `tags` VARCHAR(255), id_user int)
BEGIN
DECLARE t int;
START TRANSACTION;
SET t=(SELECT tagset_id FROM user WHERE user_id=id_user);
CALL update_tagsub_tagset(tags, t);
UPDATE `user` SET `user_name`=name, user_surname=surname, user_patronymic=patronymic, `user_date`=rdate, `user_residence`=residence, user_gender=gender, user_education=education WHERE `user_id`=id_user;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user_userset`(IN `mylist` VARCHAR(255), IN `id_userset` INT)
body:
BEGIN
START TRANSACTION; 
IF mylist = '' THEN LEAVE body; END IF;
  DELETE FROM user_userset WHERE userset_id=id_userset;
  SET @saTail = mylist;
  WHILE @saTail != '' DO
    SET @saHead = SUBSTRING_INDEX(@saTail, ',', 1);
    SET @us = SUBSTRING_INDEX(@saHead, '.', 1);
    SET @st = SUBSTRING_INDEX(@saHead, '.', -1);
        
    
    SET @i=LENGTH(@saHead)+1;
    SET @saTail = SUBSTRING( @saTail, @i+1 );
    SET @t=CAST(@us AS SIGNED);
    SET @y=CAST(@st AS SIGNED);
    INSERT INTO `user_userset` (`user_id`,`userset_id`, `user_userset_status_map_id`) VALUES (@t, id_userset, @y);
  END WHILE;
COMMIT; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `author`
--
CREATE TABLE IF NOT EXISTS `author` (
`id` int(11)
,`name` varchar(255)
,`family` varchar(255)
,`patronymic` varchar(255)
,`birthday` date
,`residence` varchar(45)
,`gender` varchar(10)
,`education` varchar(255)
);
-- --------------------------------------------------------

--
-- Структура таблицы `authorization`
--

CREATE TABLE IF NOT EXISTS `authorization` (
  `authorization_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `authorization_login` varchar(255) DEFAULT NULL,
  `authorization_password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`authorization_id`),
  KEY `authorization_fk1` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Дамп данных таблицы `authorization`
--

INSERT INTO `authorization` (`authorization_id`, `user_id`, `authorization_login`, `authorization_password`) VALUES
(1, 1, 'blasterav', '123'),
(2, 2, 'legion', '123'),
(3, 3, 'qwe', '123'),
(4, 4, 'poper', '123'),
(5, 5, 'nider', '123');

-- --------------------------------------------------------

--
-- Структура таблицы `event`
--

CREATE TABLE IF NOT EXISTS `event` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `userset_id` int(11) DEFAULT NULL,
  `event_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `event_fk1` (`userset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `eventset`
--

CREATE TABLE IF NOT EXISTS `eventset` (
  `eventset_id` int(11) NOT NULL AUTO_INCREMENT,
  `eventset_title` text,
  `paperset_id` int(11) DEFAULT NULL,
  `userset_id` int(11) DEFAULT NULL,
  `eventset_visible` int(11) NOT NULL,
  `eventset_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`eventset_id`),
  KEY `collection_id` (`paperset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `eventset_event`
--

CREATE TABLE IF NOT EXISTS `eventset_event` (
  `eventset_event_id` int(11) NOT NULL AUTO_INCREMENT,
  `eventset_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`eventset_event_id`),
  KEY `eventset_event_fk1` (`eventset_id`),
  KEY `eventset_event_fk2` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `event_paperset`
--

CREATE TABLE IF NOT EXISTS `event_paperset` (
  `event_paperset_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_paperset_id`),
  KEY `event_collection_fk1` (`event_id`),
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `message`
--

CREATE TABLE IF NOT EXISTS `message` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_text` text,
  `message_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=18 ;

--
-- Дамп данных таблицы `message`
--

INSERT INTO `message` (`message_id`, `message_text`, `message_url`) VALUES
(1, 'uraaaa!!!!!!', NULL),
(2, 'Aeeee!!!!', NULL),
(3, 'Привет)Как дела??', NULL),
(4, 'Дела нормально.Сам как??', NULL),
(5, 'Пойдешь в кино??', NULL),
(6, 'Да)))А на кокой фильм??', NULL),
(7, 'Сегдня вроде какой то ноывй начался)', NULL),
(8, 'Ты домашку сделал??', NULL),
(9, 'Неее...не успел вчера в клуб ходил))', NULL),
(10, 'исправить 1', NULL),
(11, 'исправить 2', NULL),
(12, 'тестовый пример', ''),
(13, 'qwe', ''),
(14, 'ewqewqewq', ''),
(15, 'dsadsa', ''),
(16, 'dasdsa', ''),
(17, 'интересная статья', '');

-- --------------------------------------------------------

--
-- Структура таблицы `messageset`
--

CREATE TABLE IF NOT EXISTS `messageset` (
  `messageset_id` int(11) NOT NULL AUTO_INCREMENT,
  `messageset_title` varchar(255) NOT NULL,
  `userset_id` int(11) NOT NULL,
  `messageset_discription` varchar(255) NOT NULL,
  PRIMARY KEY (`messageset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=15 ;

--
-- Дамп данных таблицы `messageset`
--

INSERT INTO `messageset` (`messageset_id`, `messageset_title`, `userset_id`, `messageset_discription`) VALUES
(1, '', 16, 'комментарии'),
(2, '', 18, 'Комментарии'),
(3, 'эксп', 19, 'экспертиза'),
(4, 'эксп', 20, 'комментарии'),
(5, 'эксп', 22, 'экспертиза'),
(6, 'эксп', 23, 'комментарии'),
(7, 'эксп', 25, 'экспертиза'),
(8, 'эксп', 26, 'комментарии'),
(9, 'эксп', 29, 'экспертиза'),
(10, 'эксп', 30, 'комментарии'),
(11, 'эксп', 33, 'экспертиза'),
(12, 'эксп', 34, 'комментарии'),
(13, 'эксп', 42, 'экспертиза'),
(14, 'эксп', 43, 'комментарии');

-- --------------------------------------------------------

--
-- Структура таблицы `message_messageset`
--

CREATE TABLE IF NOT EXISTS `message_messageset` (
  `message_id` int(11) DEFAULT NULL,
  `messageset_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message_messageset_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `message_messageset`
--

INSERT INTO `message_messageset` (`message_id`, `messageset_id`, `user_id`, `message_messageset_date`) VALUES
(16, 10, 4, '2013-09-26 06:54:17'),
(17, 12, 1, '2013-10-03 10:59:46');

-- --------------------------------------------------------

--
-- Структура таблицы `paper`
--

CREATE TABLE IF NOT EXISTS `paper` (
  `paper_id` int(11) NOT NULL AUTO_INCREMENT,
  `paper_uploaded_file_url` varchar(255) DEFAULT NULL,
  `paper_title` varchar(255) DEFAULT NULL,
  `paper_abstract` text,
  `paper_bibliography` text,
  `paper_status_map_id` int(11) DEFAULT NULL,
  `userset_id` int(11) NOT NULL,
  `paper_visible` int(11) NOT NULL,
  `paper_description` varchar(255) DEFAULT NULL,
  `tagset_id` int(11) NOT NULL,
  PRIMARY KEY (`paper_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Дамп данных таблицы `paper`
--

INSERT INTO `paper` (`paper_id`, `paper_uploaded_file_url`, `paper_title`, `paper_abstract`, `paper_bibliography`, `paper_status_map_id`, `userset_id`, `paper_visible`, `paper_description`, `tagset_id`) VALUES
(1, '111http://elibrary.ru/titles.asp', '111THE VALUE RELEVANCE OF TRANSPARENCY AND CORPORATE GOVERNANCE IN MALAYSIA BEFORE AND AFTER THE ASIAN FINANCIAL CRISIS', '111Использование электронных научных журналов в работе Центральной научной библиотеки Дальневосточного отделения РАН и Зональной научной библиотеки Дальневосточного государственного университета. Электронно-информационный консорциум в информационном обеспечении российской науки. Направления деятельности консорциума.', '', 4, 28, 0, '111Освещаются вопросы создания и эксплуатации автоматизированных систем управления технологическими процессами, современных систем связи, информационно-измерительных систем, систем автоматизированного проектирования', 10),
(2, 'http://elibrary.ru/titles.asp', 'THE VALUE RELEVANCE OF TRANSPARENCY AND CORPORATE GOVERNANCE IN MALAYSIA BEFORE AND AFTER THE ASIAN FINANCIAL CRISIS', 'Использование электронных научных журналов в работе Центральной научной библиотеки Дальневосточного отделения РАН и Зональной научной библиотеки Дальневосточного государственного университета. Электронно-информационный консорциум в информационном обеспечении российской науки. Направления деятельности консорциума.', 'пусто', 4, 32, 0, 'Освещаются вопросы создания и эксплуатации автоматизированных систем управления технологическими процессами, современных систем связи, информационно-измерительных систем, систем автоматизированного проектирования', 11),
(3, 'http://elibrary.ru/item.asp?id=20142569', 'ЭНЕРГОСБЕРЕЖЕНИЕ В РОМЫШЛЕННОСТИ', 'В учебнике подробно рассмотрены законодательные нормативные основы энергосбережения, дана характеристика государственной про-грамме РФ по повышению энергоэффективности, освящены вопросы оценки ресурсопотребления и составления энергетических балансов промышленного предприятия. Особое внимание в учебнике уделено вопросам выбора оптимальных энерго- и ресурсосберегающих мероприятий и их экономической эффективности. Материал представлен с учетом новейших достижений и тенденций развития в области энергетики и ресурсосбережения. Учебник предназначен для студентов высших технических учебных заведений, обучающихся по направлениям: «Конструкторско-технологическое обеспечение машиностроительных производств», «Автоматизация технологических процессов и производств», а также может быть полезен студентам, обучающимся по направлениям: «Электроэнергетика и электротехника», «Теплоэнергетика и тепло-техника», аспирантам и инженерно-техническим работникам, занимающимся проблемами энергосбережения в промышленном секторе экономики.', '1. 	 МДК 1-01.2002. Методические указания по проведению энергоресурсоаудита в жилищно-коммунальном хозяйстве.	  2. 	 Федеральный закон от 23.11.2009 № 261-ФЗ «Об энергосбережении и о повышении энергетической эффективности и о внесении изменений в отдельные законодательные акты Российской Федерации».	  3. 	 ГОСТ Р 51387-99 Энергосбережение. Нормативно-методическое обеспечение. Основные положения.	  4. 	 ГОСТ 30167-95 Ресурсосбережение. Порядок установления показателей ресурсосбережения в документации на продукцию.	  5. 	 Практическое пособие по выбору и разработке энергосберегающих проектов. В семи разделах. Под общей редакцией д.т.н. О.Л. Данилова, П.А. Костюченко, 2006. 668 с.	  6. 	 Т.Х. Гулбрандсен, Л.П. Падалко, В.Л. Червинский Энергоэффективность и энергетический менеджмент. Минск: БГАТУ, 2010. -240 с.	  7. 	 Международный стандарт ISO 50001:2011 1-ое издание Системы энергоменеджмента -Требования с руководством по применению.	  8. 	 Портал-энерго «Эффективное энергосбережение» www.portal-energo.ru.	  9. 	 Государственная информационная система в области энергосбережения и повышения энергетической эффективности www.gisee.ru.	  10. 	 Государственная программа Российской Федерации «Энергосбережение и повышение энергетической эффективности на период до 2020 года», утвержденная распоряжением Правительства Российской Федерации от 27 декабря 2010 г. № 2446-р.', 4, 36, 0, 'нету', 12),
(4, 'ewq', 'ewq', 'ewq', 'ewq', 4, 37, 0, 'ewq', 13),
(5, 'ewq', 'ewq', 'ewq', 'ewq', 4, 38, 0, 'ewq', 14),
(6, 'dsa', 'dsa', 'dsa', 'das', 4, 39, 0, 'das', 15),
(7, 'ewq', 'ewq', 'ewq', 'ewq', 4, 40, 0, 'ewq', 19),
(8, 'ewq', 'ewq', 'ewq', 'ewq', 4, 41, 0, 'ewq', 20);

-- --------------------------------------------------------

--
-- Структура таблицы `paperset`
--

CREATE TABLE IF NOT EXISTS `paperset` (
  `paperset_id` int(11) NOT NULL AUTO_INCREMENT,
  `userset_id` int(11) DEFAULT NULL,
  `paperset_title` varchar(255) DEFAULT NULL,
  `paperset_status_map_id` int(11) DEFAULT NULL,
  `paperset_imprint` varchar(255) DEFAULT NULL,
  `paperset_description` varchar(255) DEFAULT NULL,
  `messageset_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`paperset_id`),
  KEY `collectionset_fk2` (`userset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `paperset`
--

INSERT INTO `paperset` (`paperset_id`, `userset_id`, `paperset_title`, `paperset_status_map_id`, `paperset_imprint`, `paperset_description`, `messageset_id`) VALUES
(1, 15, 'AUTOMATION AND REMOTE CONTROL', 2, '111Общество с ограниченной ответственностью Международная академическая издательская компания "Наука/Интерпериодика"', '111Avtomatika i Telemekhanika, from the Russian Academy of Sciences, presents current research in active areas of automation and remote control technology.', 1),
(2, 17, 'Вестник БГУ', 1, 'Федеральное бюджетное образовательное учреждение высшего профессионального образования "Морской государственный университет им. адмирала Г.И. Невельского"', 'Периодическое научно-техническое и информационно-аналитическое издание на английском языке о достижениях и проблемных вопросах в сфере морской деятельности России и стран АТР', 2);

-- --------------------------------------------------------

--
-- Структура таблицы `paperset_status_map`
--

CREATE TABLE IF NOT EXISTS `paperset_status_map` (
  `paperset_status_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `paperset_status_map_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`paperset_status_map_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `paperset_status_map`
--

INSERT INTO `paperset_status_map` (`paperset_status_map_id`, `paperset_status_map_name`) VALUES
(1, 'open'),
(2, 'close');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `paper_authors`
--
CREATE TABLE IF NOT EXISTS `paper_authors` (
`paper_id` int(11)
,`author_id` int(11)
);
-- --------------------------------------------------------

--
-- Структура таблицы `paper_linkset`
--

CREATE TABLE IF NOT EXISTS `paper_linkset` (
  `paper_id` int(11) NOT NULL,
  `linkset_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `paper_paperset`
--

CREATE TABLE IF NOT EXISTS `paper_paperset` (
  `paper_paperset_id` int(11) NOT NULL AUTO_INCREMENT,
  `paper_id` int(11) NOT NULL,
  `paperset_id` int(11) NOT NULL,
  `userset_id` int(11) NOT NULL,
  `messageset_id` int(11) DEFAULT NULL,
  `paper_position_begin` varchar(45) NOT NULL,
  `paper_position_end` varchar(45) NOT NULL,
  `messageset_com_id` int(11) NOT NULL,
  PRIMARY KEY (`paper_paperset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Дамп данных таблицы `paper_paperset`
--

INSERT INTO `paper_paperset` (`paper_paperset_id`, `paper_id`, `paperset_id`, `userset_id`, `messageset_id`, `paper_position_begin`, `paper_position_end`, `messageset_com_id`) VALUES
(1, 2, 1, 31, 9, '1', '10', 10),
(2, 3, 1, 35, 11, '5', '8', 12),
(3, 1, 1, 44, 13, '2', '6', 14);

-- --------------------------------------------------------

--
-- Структура таблицы `paper_status_map`
--

CREATE TABLE IF NOT EXISTS `paper_status_map` (
  `paper_status_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `paper_status_map_name` varchar(45) NOT NULL,
  PRIMARY KEY (`paper_status_map_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Дамп данных таблицы `paper_status_map`
--

INSERT INTO `paper_status_map` (`paper_status_map_id`, `paper_status_map_name`) VALUES
(1, 'developing'),
(2, 'examination'),
(3, 'confirmed'),
(4, 'published');

-- --------------------------------------------------------

--
-- Структура таблицы `tag`
--

CREATE TABLE IF NOT EXISTS `tag` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_text` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `tagset`
--

CREATE TABLE IF NOT EXISTS `tagset` (
  `tagset_id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`tagset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=22 ;

--
-- Дамп данных таблицы `tagset`
--

INSERT INTO `tagset` (`tagset_id`) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20),
(21);

-- --------------------------------------------------------

--
-- Структура таблицы `tagsub`
--

CREATE TABLE IF NOT EXISTS `tagsub` (
  `tagsub_id` int(11) NOT NULL AUTO_INCREMENT,
  `tagsub_text` varchar(255) NOT NULL,
  PRIMARY KEY (`tagsub_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `tagsub_tagset`
--

CREATE TABLE IF NOT EXISTS `tagsub_tagset` (
  `tagset_id` int(11) NOT NULL,
  `tagsub_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `tagsub_tagset`
--

INSERT INTO `tagsub_tagset` (`tagset_id`, `tagsub_id`) VALUES
(7, 4),
(7, 6),
(7, 7),
(8, 12),
(8, 45),
(8, 32),
(8, 15),
(9, 2),
(9, 5),
(9, 8),
(9, 15),
(11, 13),
(11, 16),
(11, 19),
(12, 1),
(12, 4),
(12, 6),
(12, 8),
(12, 9),
(12, 14),
(5, 5),
(5, 6),
(5, 7),
(10, 4),
(10, 5),
(10, 6),
(10, 7),
(10, 8),
(10, 9),
(6, 1),
(6, 2),
(6, 3),
(6, 4),
(13, 1),
(13, 2),
(13, 24),
(14, 1),
(14, 2),
(14, 3),
(14, 4),
(14, 5),
(15, 1),
(15, 2),
(15, 3),
(15, 4),
(19, 1),
(19, 2),
(19, 3),
(19, 4),
(20, 1),
(20, 2),
(20, 3),
(20, 4),
(20, 5),
(21, 1),
(21, 2),
(21, 3),
(21, 4),
(21, 5);

-- --------------------------------------------------------

--
-- Структура таблицы `tag_tagsub`
--

CREATE TABLE IF NOT EXISTS `tag_tagsub` (
  `tag_tagset_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `tagsub_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_tagset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `type_object_map`
--

CREATE TABLE IF NOT EXISTS `type_object_map` (
  `type_object_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `type_object_map_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`type_object_map_id`),
  UNIQUE KEY `type_object_map_id` (`type_object_map_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

--
-- Дамп данных таблицы `type_object_map`
--

INSERT INTO `type_object_map` (`type_object_map_id`, `type_object_map_name`) VALUES
(1, 'paper'),
(2, 'paper_paperset'),
(3, 'paperset'),
(4, 'messageset'),
(5, 'event'),
(6, 'eventset'),
(7, 'standart');

-- --------------------------------------------------------

--
-- Структура таблицы `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(255) DEFAULT NULL,
  `user_surname` varchar(255) NOT NULL,
  `user_patronymic` varchar(255) NOT NULL,
  `user_date` date DEFAULT NULL,
  `user_residence` varchar(45) DEFAULT NULL,
  `user_gender` varchar(10) NOT NULL,
  `user_education` varchar(255) NOT NULL,
  `tagset_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- Дамп данных таблицы `user`
--

INSERT INTO `user` (`user_id`, `user_name`, `user_surname`, `user_patronymic`, `user_date`, `user_residence`, `user_gender`, `user_education`, `tagset_id`) VALUES
(1, 'Рыгзынов', 'Алексей', 'Феликсович', '1991-11-27', 'Улан-Удэ', 'муж', 'незаконченное высшее', 5),
(2, 'Радна', 'Балданов', 'Григорьевич', '1990-10-17', 'Улан-Удэ', 'муж', 'высшее', 6),
(3, 'Антонов', 'Илья', 'Александрович', '1990-12-23', 'Улан-Удэ', 'муж', 'высшее', 7),
(4, 'Антонова', 'Василиса', 'Михайловна ', '1984-01-12', 'Улан-Удэ', 'жен', 'высшее', 8),
(5, 'Аржаных', 'Анна', 'Сергеевна', '1993-03-13', 'Улан-Удэ', 'жен', 'незаконченное высшее', 9),
(6, 'dsa', 'dsa', 'dsa', '0000-00-00', 'dsa', 'dsa', 'dsa', 21);

-- --------------------------------------------------------

--
-- Структура таблицы `userset`
--

CREATE TABLE IF NOT EXISTS `userset` (
  `userset_id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`userset_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=45 ;

--
-- Дамп данных таблицы `userset`
--

INSERT INTO `userset` (`userset_id`) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20),
(21),
(22),
(23),
(24),
(25),
(26),
(27),
(28),
(29),
(30),
(31),
(32),
(33),
(34),
(35),
(36),
(37),
(38),
(39),
(40),
(41),
(42),
(43),
(44);

-- --------------------------------------------------------

--
-- Структура таблицы `user_message_read`
--

CREATE TABLE IF NOT EXISTS `user_message_read` (
  `user_id` int(11) DEFAULT NULL,
  `messageset_id` int(11) DEFAULT NULL,
  `user_message_read_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `user_userset`
--

CREATE TABLE IF NOT EXISTS `user_userset` (
  `user_id` int(11) DEFAULT NULL,
  `userset_id` int(11) DEFAULT NULL,
  `user_userset_status_map_id` int(11) DEFAULT NULL,
  KEY `user_userset_fk1` (`user_id`),
  KEY `user_userset_fk2` (`userset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `user_userset`
--

INSERT INTO `user_userset` (`user_id`, `userset_id`, `user_userset_status_map_id`) VALUES
(1, 3, 3),
(2, 3, 2),
(3, 3, 2),
(4, 3, 2),
(5, 3, 2),
(6, 3, 2),
(1, 5, 3),
(2, 5, 2),
(3, 5, 2),
(4, 5, 2),
(5, 5, 2),
(6, 5, 2),
(1, 3, 3),
(2, 3, 2),
(3, 3, 2),
(4, 3, 2),
(5, 3, 2),
(1, 5, 3),
(2, 5, 2),
(3, 5, 2),
(1, 7, 3),
(2, 7, 2),
(1, 9, 2),
(2, 9, 2),
(1, 11, 2),
(2, 11, 2),
(4, 13, 3),
(1, 13, 2),
(2, 13, 2),
(3, 13, 3),
(4, 17, 3),
(1, 17, 2),
(2, 17, 2),
(3, 17, 3),
(3, 27, 3),
(3, 31, 3),
(1, 32, 1),
(2, 32, 1),
(4, 35, 1),
(5, 35, 1),
(1, 36, 1),
(2, 36, 1),
(3, 36, 1),
(5, 1, 1),
(4, 1, 1),
(4, 28, 1),
(5, 28, 1),
(4, 28, 1),
(1, 15, 2),
(2, 15, 2),
(3, 15, 3),
(1, 37, 1),
(2, 37, 1),
(1, 38, 1),
(2, 38, 1),
(1, 39, 1),
(2, 39, 1),
(1, 40, 1),
(2, 40, 1),
(1, 41, 1),
(2, 41, 1),
(1, 44, 2),
(4, 44, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `user_userset_status_map`
--

CREATE TABLE IF NOT EXISTS `user_userset_status_map` (
  `user_userset_status_map_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_userset_status_map_name` varchar(45) NOT NULL,
  PRIMARY KEY (`user_userset_status_map_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Дамп данных таблицы `user_userset_status_map`
--

INSERT INTO `user_userset_status_map` (`user_userset_status_map_id`, `user_userset_status_map_name`) VALUES
(1, 'author'),
(2, 'expert'),
(3, 'vladelec'),
(4, 'creator'),
(5, 'stand');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_authorization`
--
CREATE TABLE IF NOT EXISTS `view_authorization` (
`id` int(11)
,`user_id` int(11)
,`login` varchar(255)
,`password` varchar(255)
);
-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_message`
--
CREATE TABLE IF NOT EXISTS `view_message` (
`message_id` int(11)
,`message_text` text
,`message_url` varchar(255)
);
-- --------------------------------------------------------

--
-- Структура таблицы `view_messageset`
--
-- используется(#1356 - View 'test_dump.view_messageset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)
-- Ошибка считывания данных: (#1356 - View 'test_dump.view_messageset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)

-- --------------------------------------------------------

--
-- Структура таблицы `view_message_messageset`
--
-- используется(#1356 - View 'test_dump.view_message_messageset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)
-- Ошибка считывания данных: (#1356 - View 'test_dump.view_message_messageset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)

-- --------------------------------------------------------

--
-- Структура таблицы `view_message_read`
--
-- используется(#1356 - View 'test_dump.view_message_read' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)
-- Ошибка считывания данных: (#1356 - View 'test_dump.view_message_read' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_paper`
--
CREATE TABLE IF NOT EXISTS `view_paper` (
`paper_id` int(11)
,`paper_uploaded_file_url` varchar(255)
,`paper_title` varchar(255)
,`paper_abstract` text
,`paper_bibliography` text
,`paper_status_map_id` int(11)
,`userset_id` int(11)
,`paper_visible` int(11)
,`paper_description` varchar(255)
);
-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_paperset`
--
CREATE TABLE IF NOT EXISTS `view_paperset` (
`paperset_id` int(11)
,`userset_id` int(11)
,`paperset_title` varchar(255)
,`paperset_status_map_id` int(11)
,`paperset_imprint` varchar(255)
,`paperset_description` varchar(255)
,`messageset_id` int(11)
);
-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_paper_paperset`
--
CREATE TABLE IF NOT EXISTS `view_paper_paperset` (
`paper_paperset_id` int(11)
,`paper_id` int(11)
,`paperset_id` int(11)
,`userset_id` int(11)
,`messageset_id` int(11)
,`paper_position_begin` varchar(45)
,`paper_position_end` varchar(45)
,`messageset_com_id` int(11)
);
-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_type_object`
--
CREATE TABLE IF NOT EXISTS `view_type_object` (
`type_object_map_id` int(11)
,`type_object_map_name` varchar(45)
);
-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_user_role`
--
CREATE TABLE IF NOT EXISTS `view_user_role` (
`user_id` int(11)
,`user_userset_status_map_id` int(11)
,`type_object_map_id` int(11)
,`object_id` int(11)
);
-- --------------------------------------------------------

--
-- Структура таблицы `view_user_userset`
--
-- используется(#1356 - View 'test_dump.view_user_userset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)
-- Ошибка считывания данных: (#1356 - View 'test_dump.view_user_userset' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them)

-- --------------------------------------------------------

--
-- Структура для представления `author`
--
DROP TABLE IF EXISTS `author`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `author` AS select `user`.`user_id` AS `id`,`user`.`user_name` AS `name`,`user`.`user_surname` AS `family`,`user`.`user_patronymic` AS `patronymic`,`user`.`user_date` AS `birthday`,`user`.`user_residence` AS `residence`,`user`.`user_gender` AS `gender`,`user`.`user_education` AS `education` from `user`;

-- --------------------------------------------------------

--
-- Структура для представления `paper_authors`
--
DROP TABLE IF EXISTS `paper_authors`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `paper_authors` AS select `paper`.`paper_id` AS `paper_id`,`user_userset`.`user_id` AS `author_id` from ((`paper` join `user_userset`) join `userset`) where ((`paper`.`userset_id` = `userset`.`userset_id`) and (`userset`.`userset_id` = `user_userset`.`userset_id`));

-- --------------------------------------------------------

--
-- Структура для представления `view_authorization`
--
DROP TABLE IF EXISTS `view_authorization`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_authorization` AS select `authorization`.`authorization_id` AS `id`,`authorization`.`user_id` AS `user_id`,`authorization`.`authorization_login` AS `login`,`authorization`.`authorization_password` AS `password` from `authorization`;

-- --------------------------------------------------------

--
-- Структура для представления `view_message`
--
DROP TABLE IF EXISTS `view_message`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_message` AS select `message`.`message_id` AS `message_id`,`message`.`message_text` AS `message_text`,`message`.`message_url` AS `message_url` from `message`;

-- --------------------------------------------------------

--
-- Структура для представления `view_paper`
--
DROP TABLE IF EXISTS `view_paper`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_paper` AS select `paper`.`paper_id` AS `paper_id`,`paper`.`paper_uploaded_file_url` AS `paper_uploaded_file_url`,`paper`.`paper_title` AS `paper_title`,`paper`.`paper_abstract` AS `paper_abstract`,`paper`.`paper_bibliography` AS `paper_bibliography`,`paper`.`paper_status_map_id` AS `paper_status_map_id`,`paper`.`userset_id` AS `userset_id`,`paper`.`paper_visible` AS `paper_visible`,`paper`.`paper_description` AS `paper_description` from `paper`;

-- --------------------------------------------------------

--
-- Структура для представления `view_paperset`
--
DROP TABLE IF EXISTS `view_paperset`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_paperset` AS select `paperset`.`paperset_id` AS `paperset_id`,`paperset`.`userset_id` AS `userset_id`,`paperset`.`paperset_title` AS `paperset_title`,`paperset`.`paperset_status_map_id` AS `paperset_status_map_id`,`paperset`.`paperset_imprint` AS `paperset_imprint`,`paperset`.`paperset_description` AS `paperset_description`,`paperset`.`messageset_id` AS `messageset_id` from `paperset`;

-- --------------------------------------------------------

--
-- Структура для представления `view_paper_paperset`
--
DROP TABLE IF EXISTS `view_paper_paperset`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_paper_paperset` AS select `paper_paperset`.`paper_paperset_id` AS `paper_paperset_id`,`paper_paperset`.`paper_id` AS `paper_id`,`paper_paperset`.`paperset_id` AS `paperset_id`,`paper_paperset`.`userset_id` AS `userset_id`,`paper_paperset`.`messageset_id` AS `messageset_id`,`paper_paperset`.`paper_position_begin` AS `paper_position_begin`,`paper_paperset`.`paper_position_end` AS `paper_position_end`,`paper_paperset`.`messageset_com_id` AS `messageset_com_id` from `paper_paperset`;

-- --------------------------------------------------------

--
-- Структура для представления `view_type_object`
--
DROP TABLE IF EXISTS `view_type_object`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_type_object` AS select `type_object_map`.`type_object_map_id` AS `type_object_map_id`,`type_object_map`.`type_object_map_name` AS `type_object_map_name` from `type_object_map`;

-- --------------------------------------------------------

--
-- Структура для представления `view_user_role`
--
DROP TABLE IF EXISTS `view_user_role`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_user_role` AS select `user_userset`.`user_id` AS `user_id`,`user_userset`.`user_userset_status_map_id` AS `user_userset_status_map_id`,`type_object_map`.`type_object_map_id` AS `type_object_map_id`,`paper`.`paper_id` AS `object_id` from ((`user_userset` join `type_object_map`) join `paper`) where ((`type_object_map`.`type_object_map_id` = 1) and (`paper`.`userset_id` = `user_userset`.`userset_id`)) union all select `user_userset`.`user_id` AS `user_id`,`user_userset`.`user_userset_status_map_id` AS `user_userset_status_map_id`,`type_object_map`.`type_object_map_id` AS `type_object_map_id`,`paper_paperset`.`paper_paperset_id` AS `object_id` from ((`user_userset` join `type_object_map`) join `paper_paperset`) where ((`type_object_map`.`type_object_map_id` = 2) and (`paper_paperset`.`userset_id` = `user_userset`.`userset_id`)) union all select `user_userset`.`user_id` AS `user_id`,`user_userset`.`user_userset_status_map_id` AS `user_userset_status_map_id`,`type_object_map`.`type_object_map_id` AS `type_object_map_id`,`paperset`.`paperset_id` AS `object_id` from ((`user_userset` join `type_object_map`) join `paperset`) where ((`type_object_map`.`type_object_map_id` = 3) and (`paperset`.`userset_id` = `user_userset`.`userset_id`)) union all select `user_userset`.`user_id` AS `user_id`,`user_userset`.`user_userset_status_map_id` AS `user_userset_status_map_id`,`type_object_map`.`type_object_map_id` AS `type_object_map_id`,`messageset`.`messageset_id` AS `object_id` from ((`user_userset` join `type_object_map`) join `messageset`) where ((`type_object_map`.`type_object_map_id` = 4) and (`messageset`.`userset_id` = `user_userset`.`userset_id`));

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
