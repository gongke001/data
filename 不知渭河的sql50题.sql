-- 创建数据库-- 
drop database if exists sql50;
create database sql50 default charset utf8 collate utf8_general_ci;
use sql50;
-- 创建数据表-- 
create table class(
	cid int not null auto_increment primary key,
  caption varchar(16) not null
)default charset=utf8;

create table student(
	  sid int not null auto_increment primary key,
    sname varchar(16) not null,
    gender char(1) not null,
    class_id int not null,    
    s_birth VARCHAR(20) NOT NULL ,
    constraint fk_student_class foreign key (class_id) references class(cid)
)default charset=utf8;

create table teacher(
	 tid int not null auto_increment primary key,
   tname varchar(16) not null
)default charset=utf8;

create table course(
	  course_id int not null auto_increment primary key,
    cname varchar(16) not null,
    teacher_id int not null,
    constraint fk_course_teacher foreign key (teacher_id) references teacher(tid)
)default charset=utf8;

CREATE TABLE `score` (  
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `num` int NOT NULL,
  CONSTRAINT `fk_score_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`),
  CONSTRAINT `fk_score_student` FOREIGN KEY (`student_id`) REFERENCES `student` (`sid`)
) DEFAULT CHARSET=utf8;
-- 插入数据--  
INSERT INTO class VALUES (1, '数据分析-1'), (2, '数据分析-2'), (3, '大数据-1'), (4, '大数据-2');
INSERT INTO student VALUES (1,'邹世红','男',1,"2000-01-04"),(2,'马霞','女',1,"2000-01-05"),(3,'何红','男',2,"2000-01-07"),(4,'云佳','女',1,"1999-05-14"),(5,'韩静','男',3,"1999-05-04"),(6,'金玉珍','男',4,"1999-05-19"),(7,'吴宇','女',2,"2000-11-04"),(8,'魏刚','男',1,"2000-11-13"),(9,'赵磊','男',2,"2000-11-23"),(10,'何红','女',4,"2001-08-01"),(11,'孔平','男',4,"2001-08-10"),(12,'李亮','女',1,"2001-08-30"),(13,'尤霞','女',3,"2001-01-10");
INSERT INTO teacher VALUES (1, '孙博'), (2, '渭河'), (3, '马霞'), (4, '凤欣欣');
INSERT INTO course VALUES (1, '统计学', 1), (2, 'SQL', 2), (3, 'Python', 3), (4, 'Python', 2);
INSERT INTO score VALUES (1,1,82),(1,2,54),(2,1,58),(2,2,60),(3,1,61),(4,1,46),(4,2,95),(5,1,77),(5,2,95),(5,4,56),(6,1,83),(6,2,56),(6,3,44),(7,1,53),(7,2,93),(7,3,79),(8,1,79),(8,2,80),(8,3,56),(8,4,80),(9,1,56),(9,3,70),(9,4,96),(10,1,64),(11,1,80),(11,3,69),(12,1,80),(12,3,92),(13,1,91),(13,3,84);

-- 1.查询在4日出生的学生信息
select *
from student 
where day(s_birth)=4;
-- 2.查询 2001 年出生的学生人数
select
count(1)
from student
where year(s_birth)='2001';
-- 3.查询本周过生日的学生人数（假设今天是'2023-5-15'）
select 
count(*)
from student
where week(s_birth)=week('2023-05-15');
-- 4.查询下个季度过生日的学生姓名和年龄(过了1月1日加一岁)
select sname,
timestampdiff(year,s_birth,now()) age
from student
where quarter(s_birth)=quarter(date_add(now(),interval 1 quarter));
-- 5.查询任意找一个学生，这名学生是在1月过生日的概率，结果保留三位小数。
select
round(sum(if(month(s_birth)=1,1,0))/count(*),3) as '概率'
from student;
#注意sum(if(a=1,1,0))与count(if(a=1,1,0))的区别
#count()中的条件返回1或0，均为非null，因此该函数得出的是总行数。sum()则不同，结果为1或者0的和。
#sum(if(a=1,1,0))与count(if(a=1,1,null))才是相同的

-- 6.查询课程表中所有不重复的课程名称。
select distinct cname
from course;
-- 7.查询姓“马”的学生名单。 
select sname
from student
where sname like '马%';
-- 8.查询姓“孙”和“马”的老师的个数
select 
count(1)
from teacher
where tname regexp '^[孙马]';
-- 9.查询没有教授课程的老师姓名。
select t.tname
from teacher t
left join course c
on t.tid=c.teacher_id
where c.course_id is null;
-- 10.查询除了"1"班的学生的"sid"，班级名称和年龄（按出生日期来算，过了生日加一岁）
select sid,caption,timestampdiff(year,s_birth,now()) as age
from student s
left join class c
on s.class_id=c.cid
where class_id<>1;
-- 11.查询任意一个月“数据分析-1”班有学生过生日的概率。结果：班级id和概率（xx.x%）
select 
concat(round(count(distinct month(s_birth))/12*100,2),'%') as '概率'
from student s
left join class c
on s.class_id=c.cid
and caption='数据分析-1';
-- 12.查询每个班级的班级名称、班级人数。
select caption,count(distinct sid) as c_cnt
from class cl
left join student s
on cl.cid=s.class_id
group by cl.caption;
-- 13.计算每个班级的班级名称，男生占比(升序排列)。
select caption,round(sum(if(gender='男',1,0))/count(1)*100,2) as '男生占比'
from class cl
left join student s
on cl.cid=s.class_id
group by caption
order by round(sum(if(gender='男',1,0))/count(1)*100,2)asc;
-- 14.计算每个班级的男女比例(逆序排列)。
select caption
,round(sum(if(gender='男',1,0))/sum(gender='女')*100,2) as '男女生比例'
from class cl
left join student s
on cl.cid=s.class_id
group by caption
order by round(sum(if(gender='男',1,0))/sum(gender='女')*100,2) desc;
#男女比例通常定义为男生人数除以女生人数。如果女生人数为0，则比例可能为无穷大，需要特殊处理。
-- 15.查询今年到现在每月过生日的学生人数。
select
month(s_birth) mth,
count(1) num
from student
where date_format(s_birth,'%m/%d')<=DATE_FORMAT(NOW(),'%m/%d')
group by month(s_birth)
order by mth;
#考察日期函数的使用
-- 16.查询今年到现在按照月累计过生日的学生人数，结果按照月份升序。
select month(s_birth) mth
,sum(count(distinct sid))over(order by month(s_birth)) as a_num
from student
where date_format(s_birth,'%m/%d')<=DATE_FORMAT(NOW(),'%m/%d')
group by month(s_birth)
order by mth;
#计算累计人数，不应该partition by月份了，否则是按照各月计算的累计人数
-- 17.查询每门课程的平均成绩'AVG'和成绩标准差'SD'，结果按平均成绩降序排列，标准差升序排。
select
caption
,round(avg(num),2) as avg_score
,round(stddev(num),2) as sd_score
from score sc
left join class cl
on sc.course_id=cl.cid
group by caption
order by avg_score desc,sd_score asc;
#求标准差的函数stddev()
-- 18.查询不同老师所教不同课程的平均分 (去除最高分和最低分后的平均分)
select t.tname,c.cname
,round((sum(num)-max(num)-min(num))/(count(num)-2),2) as avg_num
from  course c left join teacher t on c.teacher_id=t.tid
left join score sc on sc.course_id=c.course_id
group by c.cname,t.tname;
#去掉最高分与最低分后的平均分的计算方法，两次连接
-- 19.查询同名同姓学生名单，并统计同名人数。
select sname,count(sname) as name_cnt
from student
group by sname
having count(sname)>1;
#注意运行顺序
-- 20.查询各科被选修的学生数（只选取学生数超过3人的课程名称）。
select 
cname
,count(distinct sc.student_id) cname_cnt
from course c
left join score sc
on c.course_id=sc.course_id
group by cname
having count(distinct sc.student_id)>3;
-- 21.查询只选修了一门课程的全部学生的学号、姓名。
select s.sid,s.sname
from student s
left join score sc
on s.sid=sc.student_id
group by s.sid
having count(distinct sc.course_id)=1;
-- 22.查询至少选修两门课程的学生学号、学生姓名、选修课程数量。
select s.sid,s.sname,count(distinct sc.course_id) as course_cnt
from student s
left join score sc
on s.sid=sc.student_id
group by s.sid
having count(distinct sc.course_id)>=2;
-- 23.查询未选修所有课程的学生的学号、姓名。（两门python课程，任意选项一门就算作选修了）
select s.sid,s.sname
from student s
left join score sc
on s.sid=sc.student_id
left join course c
on c.course_id=sc.course_id
group by s.sid
having count(distinct c.cname)!=(select count(distinct cname) from course);
#共有多少门课程不应该是手动数出来的，而是应该由表达式自动计算的
-- 24.查询所有学生都选修了的课程的课程号、课程名。
select c.course_id,c.cname
from course c
left join score sc
on c.course_id=sc.course_id
group by c.course_id
having count(distinct sc.student_id)=(select count(distinct student.sid) from student);
-- 25.查询 “数据分析-1”班  每个学生的学号、姓名、总成绩、平均成绩。
select s.sid,s.sname,sum(sc.num) '总分',avg(sc.num) '平均分'
from student s
left join class cl on s.class_id=cl.cid
left join score sc on s.sid=sc.student_id
where cl.caption='数据分析-1'
group by s.sid;
-- 26.查询选修了 'Python' 的所有学生ID、学生姓名、成绩。(两门课程都修了，选择分数高的成绩)
select s.sid,s.sname,max(sc.num) as num
from student s
left join score sc on s.sid=sc.student_id
left join course c on c.course_id=sc.course_id
where c.cname='Python'
group by s.sid,s.sname;
-- 27.查询选修了"统计学"课程的男生及总体(男生和女生的总和)的人数和平均分（使用with rollup函数，本题为唯一练习的题目）
select 
ifnull(s.gender,'总体') gender
,count(s.sid) '人数'
,round(avg(sc.num),2)'平均分'
from score sc 
left join student s on s.sid=sc.student_id
left join course c on c.course_id=sc.course_id
where c.cname='统计学'
group by gender with rollup
having gender='男' or gender is null;
-- 28.查询"统计学"课程所有学生成绩的美式排名。并进行分页展示，每页显示3人的成绩和排名，显示第3页的
select s.sid,s.sname,rank()over(order by sc.num desc) '排名'
from score sc left join student s on sc.student_id=s.sid
			  left join course c on sc.course_id=c.course_id
where c.cname='统计学'
limit 6,3;
#【各种排序函数】
#【1】row _number行号函数。
#	 即使值相同也给不同的数字。1，2，3，4……
#	 使用场景1️⃣分页查询(limit+offset)比如28题2️⃣删除重复数据(配合delete使用)3️⃣生成唯一标识序列
#【2】rank美式排名。
#	 相同值给相同数字，下一数字跳过。排名有间隔。1，2，2，4，4，6……
#	 使用场景1️⃣体育竞赛2️⃣销售业绩排名3️⃣竞赛结果展示
#【3】dense_rank密集排名。
#	 相同值给相同数字，不跳过数字。排名无间隔。1，2，2，2，3，4……
#	 使用场景1️⃣学生成绩划分2️⃣薪资等级划分3️⃣客户价值分层alter
#【4】NTILE()分桶函数
#	 将结果集划分为指定数量的桶，每行分配桶号。均匀分布数据到各桶。(1,1),(2,2)……
#	 使用场景1️⃣数据分位数计算(四分位、十分位)2️⃣ABC库存分类3️⃣客户价值分段4️⃣性能基准测试
#    「示例」SELECT customer_id,total_purchases,
#			 NTILE(4) OVER (ORDER BY total_purchases DESC) AS quartile FROM customers;
#		customer_id	total_purchases	quartile
#		C001	25	1
#		C002	22	1	← 前25% (第1四分位)
#		C003	20	2
#		C004	18	2	← 25-50% (第2四分位)
#		C005	15	3
#		C006	12	3	← 50-75% (第3四分位)
#		C007	10	4
#		C008	8	4	← 后25% (第4四分位)

-- 29.查询课程'统计学'成绩第7名的学生成绩单(不考虑成绩并列)
select s.sid,s.sname,c.cname,sc.num,row_number()over(order by sc.num desc) rn
from score sc left join student s on sc.student_id=s.sid
			  left join course c on sc.course_id=c.course_id
where c.cname='统计学'
limit 6,1;
-- 30.查询所有学生和教师的编号和姓名，其中选取编号为奇数的学生，编号为偶数的教师。将他们的编号按升序排列。
(select sid id,sname name
from student
where sid%2=1)
union 
(select tid,tname
from teacher
where tid%2=0)
order by id asc;
-- 31.查询所有学生和教师的姓名和年龄，其中学生年龄为实际年龄（按出生日期来算，过了生日加一岁）），
-- 教师年龄默认为 30 岁。如果有相同的姓名，都要显示，结果中先显示学生，再显示教师。
(select sname name, timestampdiff(year,s_birth,now()) age
from student )
union all
(select tname name, '30' age
from teacher);
#union和union all
#特性			UNION								UNION ALL
#重复数据处理		自动去重								保留所有重复行
#性能			较慢（需排序去重）						更快（直接合并）
#结果集排序		不保证顺序							不保证顺序
#语法			SELECT ... UNION SELECT ...			SELECT ... UNION ALL SELECT ...
#使用场景			需要唯一结果时							需要完整数据时

#31题需要显示重复姓名，需要保留重复行，所以使用union all。30题同时筛选ID有奇有偶没有重复的情况所以可以使用union

-- 32.查询课程'1'成绩分级人数。E<60，D<70，C<80 ，B<90，A<=100 。
select 
(case when num<60 then 'E' 
	  when num<70 then 'D'
      when num<80 then 'C'
      when num<90 then 'B'
      ELSE 'A' END
) '分级'
,count(1) '人数'
from score
where course_id='1'
group by 1
order by 1;
#可以用数字指代复杂的查询字段，简单的直接写字段名可读性更强
-- 33.查询有两门及以上不及格的学生的学号、姓名、不及格课程数量。
select sid,sname,count(distinct course_id) as '不及格课程数量'
from student s left join score sc on s.sid=sc.student_id
where num<60
group by sid
having count(distinct course_id)>=2;
-- 34.查询两门及以上不及格的学生的学号、姓名、选修课程数量。
select sid,sname,count(distinct course_id) as '数量'
from student s left join score sc on s.sid=sc.student_id
where sid in (select sid
					from student s left join score sc on s.sid=sc.student_id
					where num<60
					group by sid
					having count(distinct course_id)>=2)
group by sid;
#布尔值表示真（true）或假（false）。
#布尔值在SQL中的常见用法：
#1. **条件表达式**：在WHERE子句、HAVING子句、CASE表达式中，条件表达式的结果就是布尔值。
#   SELECT * FROM table WHERE column = 1; -- 条件表达式产生布尔结果
#2. **直接使用布尔表达式**：在SELECT子句中，布尔表达式会返回0或1。
#   SELECT (5 > 3) AS result; -- 返回1（true）
#3. **在聚合函数中使用布尔表达式**：如之前例子中的`SUM(num < 60)`，这里`num < 60`对每一行都会返回一个布尔值（0或1），
#。 然后SUM函数将这些值相加，从而得到满足条件的行数。

-- 35.查询不及格人数最多的课程ID及有多少人选修过。（不考虑不并列）
select temp.course_id,count(1) cnt
from score join (
		select course_id,count(1) cnt
        from score
        where num<60
        group by course_id
        order by cnt desc
        limit 1
) temp on score.course_id=temp.course_id
group by temp.course_id;
#或者
select course_id,count(1) cnt
from score
where course_id in (
					select course_id from score where num<60
)
group by course_id
order by cnt desc
limit 1;
-- 36.查询课程“1”比课程“2”成绩高的学生ID、成绩。 
select sc1.student_id,sc1.num,sc2.num
from score sc1 
join score sc2
on sc1.student_id=sc2.student_id
and sc1.course_id=1 
and sc2.course_id=2
where sc1.num>sc2.num;
-- 37.查询同时选修了课程" sql "和" python "的学生ID、学生姓名。（两门python课程，修一个或两个都可以）
select s.sid,s.sname
from score sc left join student s on sc.student_id=s.sid
			  left join course c on sc.course_id=c.course_id
where c.cname in ('sql','python')#括号里是‘或’的关系，注意限制课程数量
group by s.sid
having count(1)>1
order by s.sid;
-- 38.查询选修了课程" 1 "但没有选修课程" 2 "的学生的学生ID、课程分数
select student_id,num
from score 
where course_id=1
and student_id not in (select sc1.student_id
						from score sc1 join score sc2 
                        on sc1.student_id=sc2.student_id
                        and sc1.course_id=1
                        and sc2.course_id=2);
#注意使用join取交集
-- 39.查询学过“渭河 ”老师授课的学生的学号、姓名。 (渭河老师教授了两门课)
select distinct s.sid,s.sname
from score sc 
join course c on c.course_id=sc.course_id
join teacher t on t.tid=c.teacher_id
join student s on sc.student_id=s.sid
where t.tname='渭河';
-- 在实际工作中，由于表的数据量和结构比较复杂，一般建议不直接join两张表，而是先select出需要的数据，再将两张表join一起
with a as(
select tname,tid from teacher where tname='渭河'
),
b as(
select sid,sname from student
),
d as(
select student_id,course_id from score
)
select distinct b.sid,b.sname
from a join course c on a.tid=c.teacher_id
		join d on c.course_id=d.course_id
        join b on b.sid=d.student_id;
-- 40.查询没学过 “渭河” 老师课的学生的学号、姓名。
select distinct s.sid,s.sname
from student s
where s.sid not in (select distinct s.sid
from score sc 
join course c on c.course_id=sc.course_id
join teacher t on t.tid=c.teacher_id
join student s on sc.student_id=s.sid
where t.tname='渭河');
-- 41.查询选修“渭河”老师所课程的学生中，成绩最高的学生姓名及其成绩（不考虑并列）
select s.sname,sc.num
from student s left join score sc
on s.sid=sc.student_id
where s.sid in (select distinct s.sid 
					from score sc 
					join course c on c.course_id=sc.course_id
					join teacher t on t.tid=c.teacher_id
					join student s on sc.student_id=s.sid
					where t.tname='渭河')
order by sc.num desc
limit 1;
-- 42.查询选修“渭河”老师所授课程的中，每门课程成绩最高的学生姓名及其成绩（考虑并列）
with rk as
(select s.sid,s.sname,c.course_id,c.cname,c.teacher_id,t.tname,sc.num,
dense_rank()over(partition by c.course_id order by sc.num desc) rk
from score sc 
join course c on c.course_id=sc.course_id
join teacher t on t.tid=c.teacher_id
join student s on sc.student_id=s.sid
where t.tname='渭河')
select cname,sname,num
from rk
where rk=1;
-- 43.查询每门课程获得最高三个分数的学生id，(考虑同一个成绩由多个学生获得) 。按照课程ID和学生ID升序
with rk as
(select sc.course_id,c.cname,sc.student_id,sc.num
,dense_rank()over(partition by c.cname order by sc.num desc) rk
from course c join score sc on c.course_id=sc.course_id)
select rk.cname,rk.student_id
from rk
where rk<4
order by rk.cname,rk.student_id;
-- 44.按照出生年月对学生进行分组，并计算每组中年龄最小学生的学号、姓名和"统计学"成绩。
select s.sid,s.sname,sc.num
from score sc join student s on sc.student_id=s.sid
				join course c on c.course_id=sc.course_id
where s.s_birth in (select max(s_birth) from student group by date_format(s_birth,'%y%m'))
and c.cname='统计学';
-- 45.查询成绩排名第二和倒数第二的差值不小于30分的课程id。（成绩排名-中式排名）






        
-- 46.查询至少有一门课与学号为“2”的学生所选的课程相同的，并且与他不是同班的学生学号和姓名。
#学生2所选课程
select distinct s.sid,s.sname
from student s 
join score sc 
on s.sid=sc.student_id
where s.class_id not in (select class_id from student where sid=2)
and sc.course_id in (select course_id from score where student_id=2)
and s.sid<>2;
#(group by s.sid having count(1)>=1)
-- 47.查询与学号为 “2” 的学生选修的课程数量相同的其他 学生学号和姓名。
select sid,sname
from student s 
join score sc 
on s.sid=sc.student_id
and sid<>2
group by sid
having count(distinct course_id)=(select count(distinct course_id) from score group by student_id having student_id=2)
;
-- 48.查询与学号为 “2” 的学生选修的课程完全相同的其他 学生学号 和 姓名 。
#学号2学生选修的课程
with a as(select distinct course_id
from score
where student_id=2)
select sid,sname
from student s join score sc on s.sid=sc.student_id and sid<>2
							 and sc.course_id in (select distinct course_id from score where student_id=2)
where student_id in (
					select student_id from score where student_id<>2
                    group by student_id
                    having count(distinct course_id)=(select count(distinct course_id) from score where student_id=2)
)
group by sid
having count(distinct course_id)=(select count(distinct course_id) from score where student_id=2);

-- ------------------增删改---------------
-- 1.创建一个表info
drop table if exists info;
create table if not exists info(
sid int(11) not null auto_increment primary key comment'自增ID',
student_id int(11) not null comment '学生ID',
course_id int(11) not null comment '课程ID',
score int(11) not null default 0 comment '成绩',
sname varchar(16) comment '学生姓名',
s_birth datetime comment '生日',
constraint fk_sc_student foreign key (student_id) references student (sid),
constraint fk_sc_course foreign key (course_id) references course (course_id)
)
default charset=utf8;
#该创建表语句有两个外键约束(constraint的两行),分别关联到student的sid列和course的course_id列
-- 2.然后将当前数据库中所有相关数据导入到 info 表中
insert into info(student_id,course_id,score,sname,s_birth)
select student_id,course_id,num score,sname,s_birth
from student s join score sc on s.sid=sc.student_id;
-- 3.把info表中“马霞”的“统计学”成绩修改为85分
update info
set score=85
where sname='马霞'
and course_id in (select course_id from course where cname='统计学');
#更新表的写法：update表名set要修改的列及修改结果
-- 4.向 info 表中插入一些记录，这些记录要求符合以下条件：1）学生ID为：没上过课程 “2” ；2）课程ID为：3；3） 成绩为：课程‘3’的最高分。
insert into info (student_id,course_id,score)
select distinct student_id,3 as course_id
,(select max(num) from score group by course_id having course_id=3) max
from score 
where course_id=3
and student_id not in(select student_id from score where course_id=2);
#本段代码筛选出从来没有选修过课程2的学生，原题答案中筛选掉的是当前行不为课程2的学生，未能排除同时选修2和其他课程的同学
-- 5.删除info表中学生“2”的课程“1”成绩。
delete from info where student_id=2 and course_id=1;
-- 6.删除teacher表中没有任何教授任何课程的老师。
SET SQL_SAFE_UPDATES = 0;
delete from teacher 
where tid not in (
select distinct teacher_id from course);
SET SQL_SAFE_UPDATES = 1;
#Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  
#To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
#直接运行本段代码时，会出现错误1175，这是因为MySQL的安全更新模式（safe update mode）要求，在更新或删除表时，必须使用WHERE条件，
#并且该条件必须使用键列（例如主键或唯一索引）。这样可以防止意外更新或删除整个表的数据。
#可以修改使用主键的where子句，或者临时禁用安全模式，目标代码运行完毕再打开安全模式，本题中SET SQL_SAFE_UPDATES =0为禁用，=1为重新打开。














