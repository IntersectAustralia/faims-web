module WebQuery

  # WEB

  def self.load_arch_entities
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT uuid
                            FROM (SELECT uuid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                WHERE aenttypeid = ?
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                                    FROM aentvalue
                                  WHERE deleted is null
                                GROUP BY uuid
                                  HAVING max(valuetimestamp)
                                    )
                           USING (uuid)
                           WHERE entDel is null
                           GROUP BY uuid
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)
             )
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE aentvalue.deleted is null
group by uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.load_arch_entities_include_deleted
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT uuid
                            FROM (SELECT uuid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                WHERE aenttypeid = ?
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                                    FROM aentvalue
                                  WHERE deleted is null
                                GROUP BY uuid
                                  HAVING max(valuetimestamp)
                                    )
                           USING (uuid)
                           GROUP BY uuid
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)
             )
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE aentvalue.deleted is null
group by uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.load_all_arch_entities
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp, group_concat(deleted) as valDel, count(*) as foo
                                    FROM aentvalue
                                GROUP BY uuid
                                  HAVING max(valuetimestamp)
                                    )
                           USING (uuid)
                           WHERE entDel is null
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)
             )
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE aentvalue.deleted is null
group by uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.load_all_arch_entities_include_deleted
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp, group_concat(deleted) as valDel, count(*) as foo
                                    FROM aentvalue
                                GROUP BY uuid
                                  HAVING max(valuetimestamp)
                                    )
                           USING (uuid)
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)
             )
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE aentvalue.deleted is null
group by uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.search_arch_entity
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT distinct uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (select uuid, valuetimestamp
                                    FROM (SELECT uuid, attributeid, max(valuetimestamp) as valuetimestamp
                                            FROM aentvalue
                                        GROUP BY uuid, attributeid
                                          HAVING max(valuetimestamp))
                                  JOIN aentvalue using (uuid, attributeid, valuetimestamp)
                                  LEFT OUTER JOIN vocabulary using (attributeid, vocabid)
                                 WHERE (freetext LIKE '%'||?||'%'
                                    OR measure LIKE '%'||?||'%'
                                    OR vocabname LIKE '%'||?||'%')
                                   AND deleted is null
                                  ) USING (uuid)
                           WHERE entDel is null
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp))
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   WHERE aentvalue.deleted is NULL
GROUP BY uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) DESC, uuid, attributename;
EOF
    )
  end

  def self.search_arch_entity_include_deleted
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(group_concat(measure || vocabname), group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, astamp, archentity.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT distinct uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (select uuid, valuetimestamp
                                    FROM (SELECT uuid, attributeid, max(valuetimestamp) as valuetimestamp
                                            FROM aentvalue
                                        GROUP BY uuid, attributeid
                                          HAVING max(valuetimestamp))
                                  JOIN aentvalue using (uuid, attributeid, valuetimestamp)
                                  LEFT OUTER JOIN vocabulary using (attributeid, vocabid)
                                 WHERE (freetext LIKE '%'||?||'%'
                                    OR measure LIKE '%'||?||'%'
                                    OR vocabname LIKE '%'||?||'%')
                                   AND deleted is null
                                  ) USING (uuid)
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp))
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   WHERE aentvalue.deleted is NULL
GROUP BY uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) DESC, uuid, attributename;
EOF
    )
  end

  def self.get_arch_entity_deleted_status
    cleanup_query(<<EOF
    SELECT uuid, deleted from ArchEntity where uuid || aenttimestamp IN
			( SELECT uuid || max(aenttimestamp) FROM archentity WHERE uuid = ?);
EOF
    )
  end

  def self.get_arch_entity_attributes
    cleanup_query(<<EOF
SELECT uuid, attributeid, vocabid, attributename, vocabname, measure, freetext, certainty, attributetype, valuetimestamp, isDirty, isDirtyReason
    FROM aentvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
    JOIN (SELECT uuid, attributeid, valuetimestamp
            FROM aentvalue
            JOIN archentity USING (uuid)
           WHERE uuid = ?
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)) USING (uuid, attributeid, valuetimestamp)
    WHERE deleted is NULl
 ORDER BY uuid, attributename ASC;
EOF
    )
  end

  def self.insert_version
    cleanup_query(<<EOF
insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, ?, 0, 1 from version;
EOF
    )
  end

  def self.insert_arch_entity
    cleanup_query(<<EOF
INSERT INTO archentity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, deleted, aenttimestamp, versionnum, parenttimestamp)
SELECT uuid, :userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, NULL, :aenttimestamp, v.versionnum,
                                                                                                  parent.aenttimestamp
FROM
  (SELECT uuid,
          max(aenttimestamp) AS aenttimestamp
   FROM archentity
   WHERE uuid = :uuid
   GROUP BY uuid)
JOIN archentity USING (uuid,
                       aenttimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT aenttimestamp
   FROM archentity
   JOIN
     (SELECT uuid,
             max(aenttimestamp) AS aenttimestamp
      FROM archentity
      GROUP BY uuid) USING (uuid,
                            aenttimestamp)
   WHERE uuid = :uuid) parent ;
EOF
    )
  end

  def self.insert_arch_entity_attribute
    cleanup_query(<<EOF
INSERT INTO aentvalue (uuid, userid, attributeid, vocabid, measure, freetext, certainty, versionnum, parenttimestamp, valuetimestamp)
SELECT :uuid, :userid, :attributeid, :vocabid, :measure, :freetext, :certainty, v.versionnum, parent.valuetimestamp, :valuetimestamp
FROM
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT valuetimestamp
   FROM aentvalue
   JOIN
     (SELECT uuid,
             attributeid,
             MAX(valuetimestamp) AS valuetimestamp
      FROM aentvalue
      GROUP BY uuid,
               attributeid) USING (uuid,
                                   attributeid,
                                   valuetimestamp)
   WHERE uuid = :uuid
     AND attributeid = :attributeid) parent ;
EOF
    )
  end

  def self.update_aent_value_as_dirty
    cleanup_query(<<EOF
      update aentvalue set isdirty = ?, isdirtyreason = ?
      where uuid is ? and valuetimestamp is ? and userid is ? and attributeid is ? and vocabid is ? and measure is ? and freetext is ? and certainty is ? and versionnum is ?
EOF
    )
  end

  def self.delete_or_undelete_arch_entity
    cleanup_query(<<EOF
INSERT INTO archentity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, deleted, versionnum, parentTimestamp)
SELECT uuid, :userid, AEntTypeID,
                       GeoSpatialColumnType,
                       GeoSpatialColumn,
                       :deleted,
                       v.versionnum,
                       parent.aenttimestamp
FROM
  (SELECT uuid,
          max(aenttimestamp) AS aenttimestamp
   FROM archentity
   WHERE uuid = :uuid
   GROUP BY uuid)
JOIN archentity USING (uuid,
                       aenttimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT aenttimestamp
   FROM archentity
   JOIN
     (SELECT uuid,
             max(aenttimestamp) AS aenttimestamp
      FROM archentity
      GROUP BY uuid) USING (uuid,
                            aenttimestamp)
   WHERE uuid = :uuid) parent ;
EOF
    )
  end

  def self.get_arch_ent_info
    cleanup_query(<<EOF
select 'Last Edit by: ' || fname || ' ' || lname || ' at '|| aenttimestamp
from archentity
join user using (userid)
where uuid = ?
  and aenttimestamp = ?;
EOF
    )
  end

  def self.get_arch_ent_attribute_info
    cleanup_query(<<EOF
select 'Last Edit by: ' || fname || ' ' || lname || ' at '|| valuetimestamp
from aentvalue
join user using (userid)
where uuid = ?
  and valuetimestamp = ?
  and attributeid = ?;
EOF
    )
  end

  def self.get_arch_ent_attribute_for_comparison
    cleanup_query(<<EOF
   select uuid, attributename, attributeid, attributetype, valuetimestamp, group_concat(coalesce(measure    || ' '  || vocabname  || '(' ||freetext||'; '|| (certainty * 100.0) || '% certain)',
                                                                                              measure    || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              measure    || ' ' || vocabname   ||' ('|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext || ')',
                                                                                              measure    || ' (' || freetext || ')',
                                                                                              measure    || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              measure,
                                                                                              vocabname,
                                                                                              freetext), ' | ') as response
FROM (  SELECT uuid, attributeid, vocabid, attributename, vocabname, measure, freetext, certainty, attributetype, valuetimestamp
          FROM aentvalue
          JOIN attributekey USING (attributeid)
          LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
          JOIN (SELECT uuid, attributeid, valuetimestamp
                  FROM aentvalue
                  JOIN archentity USING (uuid)
                 WHERE archentity.deleted is NULL
                 AND uuid = ?
              GROUP BY uuid, attributeid
                HAVING MAX(ValueTimestamp)
                   AND MAX(AEntTimestamp)) USING (uuid, attributeid, valuetimestamp)
          WHERE deleted is NULl
       ORDER BY uuid, attributename ASC)
group by uuid, attributename;
EOF
    )
  end

  def self.get_arch_ent_history
    cleanup_query(<<EOF
    select uuid, aenttimestamp as tstamp
      FROM archentity
        where uuid = ?
      union
      select uuid, valuetimestamp as tstamp
        FROM aentvalue
        where uuid = ?
        group by tstamp
      order by tstamp desc;
EOF
    )
  end

  def self.get_arch_ent_attributes_at_timestamp
    cleanup_query(<<EOF
select uuid, attributename, attributeid, group_concat(afname || ' ' || alname) as auser, astext(transform(GeoSpatialColumn,?)), group_concat(vfname || ' ' || vlname) as vuser, aenttimestamp, valuetimestamp, max(deleted) as entityDeleted, group_concat(coalesce(valdeleted,
                                                                                             measure    || ' '  || vocabname  || '(' ||freetext||'; '|| (certainty * 100.0) || '% certain)',
                                                                                             measure    || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                             vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                             measure    || ' ' || vocabname   ||' ('|| (certainty * 100.0)  || '% certain)',
                                                                                             vocabname  || ' (' || freetext || ')',
                                                                                             measure    || ' (' || freetext || ')',
                                                                                             measure    || ' (' || (certainty * 100.0) || '% certain)',
                                                                                             vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                             freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                             measure,
                                                                                             vocabname,
                                                                                             freetext), ' | ') as response, auserid, vuserid, aentforked, avalforked
FROM (  SELECT uuid, attributeid, GeoSpatialColumn, vocabid, aentuser.fname as afname, aentuser.lname as alname, valueuser.fname as vfname, valueuser.lname as vlname, attributename, vocabname, archentity.deleted, aentvalue.deleted as valdeleted, measure, freetext, certainty, attributetype, valuetimestamp, aenttimestamp, aentuser.userid as auserid, valueuser.userid as vuserid, archentity.isforked as aentforked, aentvalue.isforked as avalforked
         FROM aentvalue
         JOIN attributekey USING (attributeid)
         LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
         join archentity using (uuid)
         JOIN (SELECT uuid, attributeid, max(valuetimestamp) as valuetimestamp
                 FROM aentvalue
                WHERE uuid = ?
                  and valuetimestamp <= ?
             GROUP BY uuid, attributeid) USING (uuid, attributeid, valuetimestamp)
        JOIN (
               SELECT uuid, max(aenttimestamp) as aenttimestamp
                 FROM archentity
                WHERE uuid = ?
                  and aenttimestamp <= ?
             GROUP BY uuid) USING (uuid, aenttimestamp)
         left outer join user as aentuser on (aentuser.userid = archentity.userid)
         left outer join user as valueuser on (valueuser.userid = aentvalue.userid)
      ORDER BY uuid, attributename ASC, archentity.deleted desc)
group by uuid, attributename;
EOF
    )
  end

  def self.get_arch_ent_attributes_changes_at_timestamp
    cleanup_query(<<EOF
select uuid, 'EntityDeleted' as attribute, ifnull(deleted, 'Record Present') as 'What changed'
  from archentity
where uuid = ?
  AND aenttimestamp = ?
EXCEPT
SELECT  uuid, 'EntityDeleted', ifnull(deleted, 'Record Present')
 from ( SELECT uuid, aenttimestamp, deleted
          FROM archentity
         where uuid = ?
           AND aenttimestamp < ?
      group by uuid
      having max(aenttimestamp)
  )
union
select uuid, 'geospatialcolumn', astext(transform(GeoSpatialColumn,?))
  from archentity
where uuid = ?
  AND aenttimestamp = ?
EXCEPT
SELECT  uuid, 'geospatialcolumn', astext(transform(GeoSpatialColumn,?))
 from ( SELECT uuid, aenttimestamp, GeoSpatialColumn
          FROM archentity
         where uuid = ?
           AND aenttimestamp < ?
           group by uuid
      having max(aenttimestamp)
  )
union
select uuid, attributename, ifnull(deleted, 'Attribute Present') as 'What changed'
  from aentvalue join attributekey using (attributeid)
where uuid = ?
  AND valuetimestamp = ?
EXCEPT
SELECT  uuid, attributename, ifnull(deleted, 'Attribute Present')
 from ( SELECT uuid, valuetimestamp, deleted, attributename
                from aentvalue join attributekey using (attributeid)
      where uuid = ?
        AND valuetimestamp < ?
   group by uuid, attributeid
     having max(valuetimestamp)
  )
union
select uuid, attributename, group_concat(coalesce(measure    || ' '  || vocabname  || '(' ||freetext||'; '|| (certainty * 100.0) || '% certain)',
                                                                                              measure    || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              measure    || ' ' || vocabname   ||' ('|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext || ')',
                                                                                              measure    || ' (' || freetext || ')',
                                                                                              measure    || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              measure,
                                                                                              vocabname,
                                                                                              freetext), ' | ') as response
  from aentvalue join attributekey using (attributeid) left outer join vocabulary using (vocabid, attributeid)
where uuid = ?
  AND valuetimestamp = ?
group by uuid, attributename
EXCEPT
SELECT  uuid, attributename,  group_concat(coalesce(measure    || ' '  || vocabname  || '(' ||freetext||'; '|| (certainty * 100.0) || '% certain)',
                                                                                              measure    || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                              measure    || ' ' || vocabname   ||' ('|| (certainty * 100.0)  || '% certain)',
                                                                                              vocabname  || ' (' || freetext || ')',
                                                                                              measure    || ' (' || freetext || ')',
                                                                                              measure    || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                              measure,
                                                                                              vocabname,
                                                                                              freetext), ' | ') as response
 from ( select uuid, measure , vocabname, freetext, attributename, valuetimestamp, certainty
          from aentvalue join attributekey using (attributeid) left outer join vocabulary using (vocabid, attributeid)
         where uuid = ?
           AND valuetimestamp < ?
      group by uuid, attributeid
      having max(valuetimestamp)
  )
 group by uuid, attributename
  ;
EOF
    )
  end

  def self.insert_arch_ent_at_timestamp
     cleanup_query(<<EOF
INSERT INTO archentity (uuid, userid, doi, aenttypeid, deleted, versionnum, isDirty, isDirtyReason, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn, aenttimestamp)
SELECT uuid, :userid, doi, aenttypeid, deleted, v.versionnum, isDirty, isDirtyReason, parent.aenttimestamp, GeoSpatialColumnType,GeoSpatialColumn, :aenttimestamp
FROM archentity
JOIN
  (SELECT uuid,
          aenttimestamp
   FROM archentity
   WHERE uuid = :uuid
     AND aenttimestamp <= :timestamp
   GROUP BY uuid HAVING max(aenttimestamp)) USING (uuid,
                                                   aenttimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT aenttimestamp
   FROM archentity
   JOIN
     (SELECT uuid,
             max(aenttimestamp) AS aenttimestamp
      FROM archentity
      GROUP BY uuid) USING (uuid,
                            aenttimestamp)
   WHERE uuid = :uuid) parent ;
EOF
    )
  end


  def self.insert_aentvalue_at_timestamp
    cleanup_query(<<EOF
INSERT INTO aentvalue (uuid, userid, attributeid, vocabid, measure, freetext, certainty, deleted, versionnum, isdirty, isdirtyreason, parenttimestamp, valuetimestamp)
SELECT uuid, :userid, attributeid, vocabid, measure, freetext, certainty, deleted, v.versionnum, isdirty, isdirtyreason, parent.valuetimestamp, :valuetimestamp
FROM aentvalue
JOIN
  (SELECT uuid,
          valuetimestamp,
          attributeid
   FROM aentvalue
   WHERE uuid = :uuid
     AND attributeid = :attributeid
     AND valuetimestamp <= :timestamp
   GROUP BY uuid,
            attributeid HAVING MAX (valuetimestamp)) USING (uuid,
                                                            valuetimestamp,
                                                            attributeid),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT valuetimestamp
   FROM aentvalue
   JOIN
     (SELECT uuid,
             attributeid,
             MAX(valuetimestamp) AS valuetimestamp
      FROM aentvalue
      GROUP BY uuid,
               attributeid) USING (uuid,
                                   attributeid,
                                   valuetimestamp)
   WHERE uuid = :uuid
     AND attributeid = :attributeid) parent ;
EOF
    )
  end

  def self.get_related_arch_entities
    cleanup_query(<<EOF
SELECT uuid,
       aenttypename || ' ' || coalesce(participatesverb, 'in') || ' '|| relntypename||': '||group_concat(response,', ')
FROM
  (SELECT uuid,
          group_concat(coalesce(measure || ' ' || vocabname || '(' ||freetext||'; '|| (certainty * 100.0) || '% certain)', measure || ' (' || freetext ||'; '|| (certainty * 100.0) || '% certain)', vocabname || ' (' || freetext ||'; '|| (certainty * 100.0) || '% certain)', measure || ' ' || vocabname ||' ('|| (certainty * 100.0) || '% certain)', vocabname || ' (' || freetext || ')', measure || ' (' || freetext || ')', measure || ' (' || (certainty * 100.0) || '% certain)', vocabname || ' (' || (certainty * 100.0) || '% certain)', freetext || ' (' || (certainty * 100.0) || '% certain)', measure, vocabname, freetext), ' | ') AS response,
          aenttypename,
          participatesverb,
          relntypename
   FROM
     (SELECT uuid,
             attributeid,
             vocabid,
             attributename,
             vocabname,
             measure,
             freetext,
             certainty,
             attributetype,
             valuetimestamp,
             aenttypename,
             relntypename,
             participatesverb
      FROM aentvalue
      JOIN
        (SELECT uuid,
                attributeid,
                max(valuetimestamp) AS valuetimestamp
         FROM aentvalue
         GROUP BY uuid,
                  attributeid) USING (uuid,
                                      attributeid,
                                      valuetimestamp)
      JOIN attributekey USING (attributeid)
      JOIN archentity USING (uuid)
      JOIN
        (SELECT uuid,
                max(aenttimestamp) AS aenttimestamp
         FROM archentity
         GROUP BY uuid) USING (uuid,
                               aenttimestamp)
      JOIN
        (SELECT attributeid,
                aenttypeid
         FROM idealaent
         JOIN aenttype USING (aenttypeid)
         WHERE isIdentifier IS 'true') USING (attributeid,
                                              aenttypeid)
      LEFT OUTER JOIN vocabulary USING (vocabid,
                                        attributeid)
      JOIN
        (SELECT uuid,
                attributeid,
                valuetimestamp
         FROM aentvalue
         JOIN archentity USING (uuid)
         WHERE archentity.deleted IS NULL
         GROUP BY uuid,
                  attributeid HAVING MAX(ValueTimestamp)
         AND MAX(AEntTimestamp)) USING (uuid,
                                        attributeid,
                                        valuetimestamp)
      JOIN
        (SELECT DISTINCT uuid,
                         relationshipid,
                         participatesverb
         FROM aentreln
         JOIN
           (SELECT uuid,
                   relationshipid,
                   max(aentrelntimestamp) AS aentrelntimestamp
            FROM aentreln
            GROUP BY uuid,
                     relationshipid) USING (uuid,
                                            relationshipid,
                                            aentrelntimestamp)
         JOIN archentity USING (uuid)
         JOIN
           (SELECT uuid,
                   max(aenttimestamp) AS aenttimestamp
            FROM archentity
            GROUP BY uuid) USING (uuid,
                                  aenttimestamp)
         JOIN relationship USING (relationshipid)
         JOIN
           (SELECT relationshipid,
                   max(relntimestamp) AS relntimestamp
            FROM relationship
            GROUP BY relationshipid) USING (relationshipid,
                                            relntimestamp)
         WHERE relationshipid IN
             ( SELECT DISTINCT relationshipid
              FROM aentreln
              JOIN
                (SELECT uuid,
                        relationshipid,
                        max(aentrelntimestamp) AS aentrelntimestamp
                 FROM aentreln
                 GROUP BY uuid,
                          relationshipid having MAX(aentrelntimestamp)) USING (uuid,
                                                 relationshipid,
                                                 aentrelntimestamp)
              WHERE uuid = :uuid AND aentreln.deleted IS NULL)
           AND uuid != :uuid
           AND relationship.deleted IS NULL
           AND aentreln.deleted IS NULL
           AND archentity.deleted IS NULL) USING (uuid)
      JOIN relationship USING (relationshipid)
      JOIN
        (SELECT relationshipid,
                max(relntimestamp) AS relntimestamp
         FROM relationship
         GROUP BY relationshipid) USING (relationshipid,
                                         relntimestamp)
      JOIN relntype USING (relntypeid)
      JOIN aenttype USING (aenttypeid) )
   GROUP BY uuid,
            attributeid)
GROUP BY uuid;
EOF
    )
  end

  def self.load_relationships
    cleanup_query(<<EOF
SELECT relationshipid, RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid, astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          WHERE relntypeid = ?
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                     WHERE relnDeleted is null
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.load_relationships_include_deleted
    cleanup_query(<<EOF
SELECT relationshipid, RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid, astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          WHERE relntypeid = ?
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.load_all_relationships
    cleanup_query(<<EOF
SELECT relationshipid, RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid,astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                     WHERE relnDeleted is null
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.load_all_relationships_include_deleted
    cleanup_query(<<EOF
SELECT relationshipid, RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid,astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.search_relationship
    cleanup_query(<<EOF
SELECT relationshipid,RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid,astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT distinct relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid, vocabid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                      JOIN relnvalue using (relationshipid, attributeid, relnvaluetimestamp)
                                      LEFT OUTER JOIN vocabulary using (attributeid, vocabid)
                                     WHERE relnDeleted is null
                                       AND (freetext LIKE '%'||?||'%'
                                            OR vocabname LIKE '%'||?||'%')
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.search_relationship_include_deleted
    cleanup_query(<<EOF
SELECT relationshipid,RelnTypeName, attributename, coalesce(group_concat(vocabname, ', '), group_concat(freetext, ', ')) as response, vocabid, attributeid,astamp, relationship.deleted
   FROM ( SELECT relationshipid, attributeid, relntimestamp, relnvaluetimestamp
            FROM relationship join (select relationshipid, max(relntimestamp) as relntimestamp from relationship group by relationshipid ) using (relationshipid, relntimestamp)
            JOIN relnvalue USING (relationshipid) join  (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp from relnvalue group by relationshipid, attributeid ) using (relationshipid, attributeid, relnvaluetimestamp)
            JOIN idealreln using (relntypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND relationshipid in (SELECT distinct relationshipid
                                      FROM (SELECT relationshipid, max(relntimestamp) as relntimestamp, deleted as relnDeleted
                                              FROM relationship
                                          GROUP BY relationshipid
                                            HAVING max(relntimestamp))
                                      JOIN (SELECT relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
                                              FROM relnvalue
                                             WHERE deleted is null
                                          GROUP BY relationshipid, attributeid, vocabid
                                            HAVING max(relnvaluetimestamp)
                                        ) USING (relationshipid)
                                      JOIN relnvalue using (relationshipid, attributeid, relnvaluetimestamp)
                                      LEFT OUTER JOIN vocabulary using (attributeid, vocabid)
                                       WHERE (freetext LIKE '%'||?||'%'
                                            OR vocabname LIKE '%'||?||'%')
                                  GROUP BY relationshipid
                                  ORDER BY max(relnvaluetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                  OFFSET ?
                                    )
        GROUP BY relationshipid, attributeid
          HAVING MAX(relntimestamp)
             AND MAX(relnvaluetimestamp))
   JOIN relationship using (relationshipid, relntimestamp)
   JOIN relntype using (relntypeid)
   JOIN attributekey using (attributeid)
   JOIN relnvalue using (relationshipid, relnvaluetimestamp, attributeid)
   LEFT OUTER JOIN vocabulary using (vocabid, attributeid)
   JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
   JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM relationship GROUP BY relationshipid) USING (relationshipid)
  WHERE relnvalue.deleted is NULL
GROUP BY relationshipid, attributeid, relnvaluetimestamp
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.get_rel_deleted_status
    cleanup_query(<<EOF
    SELECT relationshipid, deleted from relationship where relationshipid || relntimestamp IN
			( SELECT relationshipid || max(relntimestamp) FROM relationship WHERE relationshipid = ?);
EOF
    )
  end

  def self.get_relationship_attributes
    cleanup_query(<<EOF
SELECT relationshipid, vocabid, attributeid, attributename, freetext, certainty, vocabname, relntypeid, attributetype, relnvaluetimestamp, isDirty, isDirtyReason
    FROM relnvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
    JOIN ( SELECT relationshipid, attributeid, relnvaluetimestamp, relntypeid
             FROM relnvalue
             JOIN relationship USING (relationshipid)
            WHERE relationshipid = ?
         GROUP BY relationshipid, attributeid
           HAVING MAX(relnvaluetimestamp)
              AND MAX(relntimestamp)
      ) USING (relationshipid, attributeid, relnvaluetimestamp)
   WHERE relnvalue.deleted is NULL
ORDER BY relationshipid, attributename asc;
EOF
    )
  end

  def self.insert_relationship
    cleanup_query(<<EOF
INSERT INTO relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, deleted, relntimestamp, versionnum, parenttimestamp)
SELECT RelationshipID, :userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, NULL, :relntimestamp, v.versionnum,
                                                                                                          parent.relntimestamp
FROM
  (SELECT relationshipid,
          max(relntimestamp) AS RelnTimestamp
   FROM relationship
   WHERE relationshipID = :relationshipid

   GROUP BY relationshipid)
JOIN relationship USING (relationshipid,
                         relntimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT relntimestamp
FROM relationship
JOIN
  (SELECT relationshipid,
          max(relntimestamp) AS relntimestamp
   FROM relationship
   GROUP BY relationshipid) USING (relationshipid,
                         relntimestamp)
WHERE relationshipid = :relationshipid) parent ;
EOF
    )
  end

  def self.insert_relationship_attribute
    cleanup_query(<<EOF
INSERT INTO relnvalue (relationshipid, userid, attributeid, vocabid, freetext, certainty, versionnum, parenttimestamp, relnvaluetimestamp)
SELECT :relationshipid, :userid, :attributeid, :vocabid, :freetext, :certainty, v.versionnum, parent.relnvaluetimestamp, :relnvaluetimestamp

FROM
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT relnvaluetimestamp
FROM relnvalue
JOIN
  (SELECT relationshipid,
          attributeid,
          MAX(relnvaluetimestamp) AS relnvaluetimestamp
   FROM relnvalue
   GROUP BY relationshipid,
            attributeid) USING (relationshipid,
                                attributeid,
                                relnvaluetimestamp)
WHERE relationshipid = :relationshipid

  AND attributeid = :attributeid) parent ;
EOF
    )
  end

  def self.update_reln_value_as_dirty
    cleanup_query(<<EOF
      update relnvalue set isdirty = ?, isdirtyreason = ?
      where relationshipid is ? and relnvaluetimestamp is ? and userid is ? and attributeid is ? and vocabid is ? and freetext is ? and certainty is ? and versionnum is ?
EOF
    )
  end

  def self.delete_or_undelete_relationship
    cleanup_query(<<EOF
INSERT INTO relationship (relationshipid, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, deleted, versionnum, parentTimestamp)
SELECT relationshipid, :userid, RelnTypeID,
                      GeoSpatialColumnType,
                      GeoSpatialColumn,
                      :deleted,
                      v.versionnum,
                      parent.relntimestamp
FROM
  (SELECT relationshipid,
          max(relntimestamp) AS relntimestamp
   FROM relationship
   WHERE relationshipid = :relationshipid

   GROUP BY relationshipid)
JOIN relationship USING (relationshipid,
                       relntimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT relntimestamp
FROM relationship
JOIN
  (SELECT relationshipid,
          max(relntimestamp) AS relntimestamp
   FROM relationship
   GROUP BY relationshipid) USING (relationshipid,
                         relntimestamp)
WHERE relationshipid = :relationshipid) parent ;
EOF
    )
  end

  def self.get_rel_info
    cleanup_query(<<EOF
select 'Last Edit by: ' || fname || ' ' || lname || ' at '|| relntimestamp
from relationship
join user using(userid)
where relationshipid = ?
  and relntimestamp = ?;
EOF
    )
  end

  def self.get_rel_attribute_info
    cleanup_query(<<EOF
select 'Last Edit by: ' || fname || ' ' || lname || ' at '|| relnvaluetimestamp
from relnvalue
join user using(userid)
where relationshipid = ?
  and relnvaluetimestamp = ?
  and attributeid = ?;
EOF
    )
  end

  def self.get_rel_attribute_for_comparison
    cleanup_query(<<EOF
   select relationshipid, attributeid, attributename, attributetype,  group_concat(coalesce(vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                         vocabname  || ' (' || freetext || ')',
                                                                                         vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         vocabname,
                                                                                         freetext), ' | ') as response
from (
SELECT relationshipid, vocabid, attributeid, attributename, freetext, certainty, vocabname, relntypeid, attributetype, relnvaluetimestamp
    FROM relnvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
    JOIN ( SELECT relationshipid, attributeid, relnvaluetimestamp, relntypeid
             FROM relnvalue
             JOIN relationship USING (relationshipid)
            WHERE relationship.deleted is NULL
            and relationshipid = ?
         GROUP BY relationshipid, attributeid
           HAVING MAX(relnvaluetimestamp)
              AND MAX(relntimestamp)
      ) USING (relationshipid, attributeid, relnvaluetimestamp)
   WHERE relnvalue.deleted is NULL
ORDER BY relationshipid, attributename asc)
group by relationshipid, attributename;
EOF
    )
  end

  def self.get_rel_history
    cleanup_query(<<EOF
    select relationshipid, relntimestamp as tstamp
      FROM relationship
      where relationshipid = ?
    union
      select relationshipid, relnvaluetimestamp as tstamp
        FROM relnvalue
        where relationshipid = ?
        group by tstamp
        order by tstamp desc;
EOF
    )
  end

  def self.get_rel_attributes_at_timestamp
    cleanup_query(<<EOF
select relationshipid, attributeid, attributename, astext(transform(GeoSpatialColumn,?)), group_concat(rfname || ' ' || rlname) as ruser,group_concat(vfname || ' ' || vlname) as rvuser, relntimestamp, relnvaluetimestamp, max(deleted), group_concat(coalesce(relnvaluedeleted, vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                        vocabname  || ' (' || freetext || ')',
                                                                                        vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                        freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                        vocabname,
                                                                                        freetext), ' | ') as response, ruserid, rvuserid, rforked, rvforked
from (
SELECT relationshipid, geospatialcolumn, vocabid, attributeid, relnuser.fname as rfname, relnuser.lname as rlname, rvalueuser.fname as vfname, rvalueuser.lname as vlname, attributename, freetext, certainty, relationship.deleted, relnvalue.deleted as relnvaluedeleted, vocabname, relntypeid, attributetype, relnvaluetimestamp, relntimestamp, relnuser.userid as ruserid, rvalueuser.userid as rvuserid, relationship.isforked as rforked, relnvalue.isforked as rvforked
   FROM relnvalue
   JOIN attributekey USING (attributeid)
   LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   join relationship using (relationshipid)
   JOIN ( SELECT relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
            FROM relnvalue
            JOIN relationship USING (relationshipid)
           WHERE relationshipid = ?
            and relnvaluetimestamp <= ?
        GROUP BY relationshipid, attributeid
     ) USING (relationshipid, attributeid, relnvaluetimestamp)
   JOIN (select relationshipid, max(relntimestamp) as relntimestamp
         from relationship
         where relationshipid = ?
         and relntimestamp <= ?
         group by relationshipid
         ) USING (relationshipid, relntimestamp)
   left outer join user as relnuser on (relnuser.userid = relationship.userid)
   left outer join user as rvalueuser on (rvalueuser.userid = relnvalue.userid)
ORDER BY relationshipid, attributename asc)
group by relationshipid, attributename;
EOF
    )
  end

  def self.get_rel_attributes_changes_at_timestamp
    cleanup_query(<<EOF
select relationshipid, 'RelationshipDeleted' as attribute, ifnull(deleted, 'Record Present') as 'What changed'
  from relationship
where relationshipid = ?
  AND relntimestamp = ?
EXCEPT
SELECT  relationshipid, 'RelationshipDeleted', ifnull(deleted, 'Record Present')
 from ( SELECT relationshipid, relntimestamp, deleted
          FROM relationship
         where relationshipid = ?
           AND relntimestamp < ?
      group by relationshipid
      having max(relntimestamp)
  )
union
select relationshipid, 'geospatialcolumn', astext(transform(GeoSpatialColumn,?))
  from relationship
where relationshipid = ?
  AND relntimestamp = ?
EXCEPT
SELECT  relationshipid, 'geospatialcolumn', astext(transform(GeoSpatialColumn,?))
 from ( SELECT relationshipid, GeoSpatialColumn
          FROM relationship
         where relationshipid = ?
           AND relntimestamp < ?
      group by relationshipid
      having max(relntimestamp)
  )
union
select relationshipid, attributename, ifnull(deleted, 'Attribute Present') as 'What changed'
  from relnvalue join attributekey using (attributeid)
where relationshipid = ?
  AND relnvaluetimestamp = ?
except
SELECT  relationshipid, attributename, ifnull(deleted, 'Attribute Present')
 from ( SELECT relationshipid, relnvaluetimestamp, deleted, attributename
          from relnvalue join attributekey using (attributeid)
         where relationshipid = ?
           AND relnvaluetimestamp < ?
      group by relationshipid, attributeid
        having max(relnvaluetimestamp)

  )
union
select relationshipid, attributename, group_concat(coalesce(vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                         vocabname  || ' (' || freetext || ')',
                                                                                         vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         vocabname,
                                                                                         freetext), ' | ') as response
  from relnvalue join attributekey using (attributeid) left outer join vocabulary using (vocabid, attributeid)
where relationshipid = ?
  AND relnvaluetimestamp = ?
group by relationshipid, attributename
EXCEPT
SELECT  relationshipid, attributename,group_concat(coalesce(vocabname  || ' (' || freetext   ||'; '|| (certainty * 100.0)  || '% certain)',
                                                                                         vocabname  || ' (' || freetext || ')',
                                                                                         vocabname  || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         freetext   || ' (' || (certainty * 100.0) || '% certain)',
                                                                                         vocabname,
                                                                                         freetext), ' | ') as response
 from ( select relationshipid, vocabname, freetext, attributename, relnvaluetimestamp, certainty
          from relnvalue join attributekey using (attributeid) left outer join vocabulary using (vocabid, attributeid)
         where relationshipid = ?
           AND relnvaluetimestamp < ?
      group by relationshipid, attributeid
        having max(relnvaluetimestamp)
  )
  group by relationshipid, attributename;

  ;
EOF
    )
  end

  def self.insert_rel_at_timestamp
    cleanup_query(<<EOF
INSERT INTO relationship (relationshipid, userid, relntypeid, deleted, versionnum, isDirty, isDirtyReason, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn, relntimestamp)
SELECT relationshipid, :userid, relntypeid, deleted, v.versionnum, isDirty, isDirtyReason, parent.relntimestamp, GeoSpatialColumnType,GeoSpatialColumn, :relntimestamp

FROM relationship
JOIN
  (SELECT relationshipid,
          relntimestamp
   FROM relationship
   WHERE relationshipid = :relationshipid

     AND relntimestamp <= :timestamp

   GROUP BY relationshipid HAVING max(relntimestamp)) USING (relationshipid,
                                                   relntimestamp),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT relntimestamp
FROM relationship
JOIN
  (SELECT relationshipid,
          max(relntimestamp) AS relntimestamp
   FROM relationship
   GROUP BY relationshipid) USING (relationshipid,
                         relntimestamp)
WHERE relationshipid = :relationshipid) parent ;
EOF
    )
  end

  def self.insert_relnvalue_at_timestamp
    cleanup_query(<<EOF
INSERT INTO relnvalue (relationshipid, userid, attributeid, vocabid, freetext, certainty, deleted, versionnum, isdirty, isdirtyreason, parenttimestamp, relnvaluetimestamp)
SELECT relationshipid, :userid, attributeid, vocabid, freetext, certainty, deleted, v.versionnum, isdirty, isdirtyreason, parent.relnvaluetimestamp, :relnvaluetimestamp

FROM relnvalue
JOIN
  (SELECT relationshipid,
          relnvaluetimestamp,
          attributeid
   FROM relnvalue
   WHERE relationshipid = :relationshipid
     AND attributeid = :attributeid
     AND relnvaluetimestamp <= :timestamp

   GROUP BY relationshipid,
            attributeid HAVING MAX (relnvaluetimestamp)) USING (relationshipid,
                                                            relnvaluetimestamp,
                                                            attributeid),
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT relnvaluetimestamp
FROM relnvalue
JOIN
  (SELECT relationshipid,
          attributeid,
          MAX(relnvaluetimestamp) AS relnvaluetimestamp
   FROM relnvalue
   GROUP BY relationshipid,
            attributeid) USING (relationshipid,
                                attributeid,
                                relnvaluetimestamp)
WHERE relationshipid = :relationshipid

  AND attributeid = :attributeid) parent ;
EOF
    )
  end

  def self.get_arch_entities_in_relationship
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(measure || vocabname, group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, max(tstamp, astamp), aentvalue.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp, group_concat(deleted) as valDel, count(*) as foo
                                    FROM aentvalue
                                GROUP BY uuid
                                  HAVING max(valuetimestamp)
                                    ) USING (uuid)
                            JOIN ( SELECT uuid, max(aentrelntimestamp) as aentrelntimestamp, deleted as aentRelnDeleted
                                             FROM aentreln
                                             where relationshipid = ?
                                             group by uuid, relationshipid
                                             HAVING max(aentrelntimestamp)
                                           ) USING (uuid)
                           WHERE entDel is null
                             AND aentRelnDeleted is null
                        ORDER BY max(aentrelntimestamp, valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp)
             )
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE aentvalue.deleted is null
group by uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.get_arch_entities_not_in_relationship
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(measure || vocabname, group_concat(vocabname, ', '), group_concat(measure, ', '), group_concat(freetext, ', ')) AS response, vocabid, attributeid, max(tstamp, astamp), aentvalue.deleted
    FROM (SELECT uuid, attributeid, valuetimestamp, aenttimestamp
            FROM archentity
            JOIN aentvalue USING (uuid)
            JOIN idealaent using (aenttypeid, attributeid)
           WHERE isIdentifier = 'true'
             AND uuid IN (SELECT distinct uuid
                            FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp, deleted as entDel
                                    FROM archentity
                                GROUP BY uuid, aenttypeid
                                  HAVING max(aenttimestamp)
                                     )
                            JOIN (select uuid, valuetimestamp
                                    FROM (SELECT uuid, attributeid, max(valuetimestamp) as valuetimestamp
                                            FROM aentvalue
                                        GROUP BY uuid, attributeid
                                          HAVING max(valuetimestamp))
                                  JOIN aentvalue using (uuid, attributeid, valuetimestamp)
                                  LEFT OUTER JOIN vocabulary using (attributeid, vocabid)
                                 WHERE (freetext LIKE '%'||?||'%'
                                    OR measure LIKE '%'||?||'%'
                                    OR vocabname LIKE '%'||?||'%')
                                   AND deleted is null
                                  ) USING (uuid)
                           WHERE entDel is null
                        ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                        LIMIT ?
                        OFFSET ?
                      )
            AND uuid NOT IN (select uuid
                               FROM (SELECT uuid, max(aentrelntimestamp) as aentrelntimestamp, deleted as aentRelnDeleted
                                       FROM aentreln
                                      WHERE relationshipid = ?
                                   GROUP BY uuid, relationshipid
                                     HAVING max(aentrelntimestamp)
                                           )
                               WHERE aentrelndeleted is null
                               )
        GROUP BY uuid, attributeid
          HAVING MAX(ValueTimestamp)
             AND MAX(AEntTimestamp))
    JOIN attributekey using (attributeid)
    JOIN aentvalue using (uuid, attributeid, valuetimestamp)
    JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
    JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
    JOIN archentity using (uuid, aenttimestamp)
    JOIN aenttype using (aenttypeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   WHERE aentvalue.deleted is NULL
GROUP BY uuid, attributeid, valuetimestamp
ORDER BY max(tstamp,astamp) DESC, uuid, attributename;
EOF
    )
  end

  def self.get_verbs_for_relationship
    cleanup_query(<<EOF
select parent from relntype where relntypeid = ? union select child from relntype where relntypeid = ?;
EOF
    )
  end

  def self.insert_arch_entity_relationship
    cleanup_query(<<EOF
INSERT INTO aentreln (UUID, RelationshipID, UserId, ParticipatesVerb, AEntRelnTimestamp, versionnum, parenttimestamp)
SELECT :uuid, :relationshipid, :userid, :verb, :aentrelntimestamp, v.versionnum,
                                                                   parent.aentrelntimestamp
FROM
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT aentrelntimestamp
FROM aentreln
JOIN
  (SELECT uuid,
          relationshipid,
          max(AEntRelnTimestamp) AS AEntRelnTimestamp
   FROM aentreln
   GROUP BY uuid,
            relationshipid) USING (uuid,
                                   relationshipid,
                                   AEntRelnTimestamp)
WHERE uuid = :uuid
  AND relationshipid = :relationshipid) parent ;
EOF
    )
  end

  def self.delete_arch_entity_relationship
    cleanup_query(<<EOF
INSERT INTO aentreln (UUID, RelationshipID, UserId, Deleted, AEntRelnTimestamp, versionnum, parenttimestamp)
SELECT :uuid, :relationshipid, :userid, 'true', :aentrelntimestamp, v.versionnum,
                                                                    parent.aentrelntimestamp
FROM
  (SELECT versionnum
   FROM VERSION
   WHERE ismerged = 1
   ORDER BY versionnum DESC LIMIT 1) v
LEFT OUTER JOIN (SELECT aentrelntimestamp
FROM aentreln
JOIN
  (SELECT uuid,
          relationshipid,
          max(AEntRelnTimestamp) AS AEntRelnTimestamp
   FROM aentreln
   GROUP BY uuid,
            relationshipid) USING (uuid,
                                   relationshipid,
                                   AEntRelnTimestamp)
WHERE uuid = :uuid
  AND relationshipid = :relationshipid) parent ;
EOF
    )
  end

  def self.get_relationships_for_arch_ent
    cleanup_query(<<EOF
SELECT relationshipid,
      relntypename,
      attributename,
      group_concat(coalesce(vocabname || ' (' || freetext ||'; '|| (certainty * 100.0) || '% certain)', vocabname || ' (' || freetext || ')', vocabname || ' (' || (certainty * 100.0) || '% certain)', freetext || ' (' || (certainty * 100.0) || '% certain)', vocabname, freetext), ' | ') AS response
FROM
 (SELECT relationshipid,
         vocabid,
         attributeid,
         attributename,
         freetext,
         certainty,
         vocabname,
         relntypeid,
         attributetype,
         relnvaluetimestamp,
         relntypename
  FROM relnvalue
  JOIN attributekey USING (attributeid)
  JOIN relationship USING (relationshipid)
  JOIN
    (SELECT relationshipid,
            max(relntimestamp) AS relntimestamp
     FROM relationship
     GROUP BY relationshipid) USING (relationshipid,
                                     relntimestamp)
  JOIN relntype USING (relntypeid)
  JOIN
    (SELECT attributeid,
            relntypeid
     FROM idealreln
     JOIN relntype USING (relntypeid)
     WHERE isIdentifier IS 'true') USING (attributeid,
                                          relntypeid)
  LEFT OUTER JOIN vocabulary USING (vocabid,
                                    attributeid)
  JOIN
    (SELECT relationshipid,
            attributeid,
            relnvaluetimestamp,
            relntypeid
     FROM relnvalue
     JOIN relationship USING (relationshipid)
     WHERE relationship.deleted IS NULL
     GROUP BY relationshipid,
              attributeid HAVING MAX(relnvaluetimestamp)
     AND MAX(relntimestamp) ) USING (relationshipid,
                                     attributeid,
                                     relnvaluetimestamp,
                                     relntypeid)
  WHERE relnvalue.deleted IS NULL
    AND relationshipid IN
      ( SELECT relationshipid
       FROM
         (SELECT relationshipid,
                 aentreln.deleted AS ardeleted,
                 archentity.deleted AS adeleted
          FROM aentreln
          JOIN archentity USING (uuid)
          JOIN
            (SELECT uuid,
                    max(aenttimestamp) AS aenttimestamp
             FROM archentity
             GROUP BY uuid) USING (uuid,
                                   aenttimestamp)
          WHERE uuid = :uuid
          GROUP BY relationshipid,
                   uuid HAVING MAX (aentrelntimestamp) )
       WHERE ardeleted IS NULL
         AND adeleted IS NULL LIMIT :limit
       OFFSET :offset )
  ORDER BY relationshipid,
           attributename ASC)
GROUP BY relationshipid,
        attributeid;
EOF
    )
  end

  def self.get_relationships_not_belong_to_arch_ent
    cleanup_query(<<EOF
SELECT relationshipid,
         relntypename,
         relntypeid,
         attributename,
         group_concat(coalesce(vocabname || ' (' || freetext ||'; '|| (certainty * 100.0) || '% certain)', vocabname || ' (' || freetext || ')', vocabname || ' (' || (certainty * 100.0) || '% certain)', freetext || ' (' || (certainty * 100.0) || '% certain)', vocabname, freetext), ' | ') AS response
  FROM
    (SELECT relationshipid,
            vocabid,
            attributeid,
            attributename,
            freetext,
            certainty,
            vocabname,
            relntypeid,
            attributetype,
            relnvaluetimestamp,
            relntypename
     FROM relnvalue
     JOIN attributekey USING (attributeid)
     JOIN relationship USING (relationshipid)
     JOIN
       (SELECT relationshipid,
               max(relntimestamp) AS relntimestamp
        FROM relationship
        GROUP BY relationshipid) USING (relationshipid,
                                        relntimestamp)
     JOIN relntype USING (relntypeid)
     JOIN
       (SELECT attributeid,
               relntypeid
        FROM idealreln
        JOIN relntype USING (relntypeid)
        WHERE isIdentifier IS 'true') USING (attributeid,
                                             relntypeid)
     LEFT OUTER JOIN vocabulary USING (vocabid,
                                       attributeid)
     JOIN
       (SELECT relationshipid,
               attributeid,
               relnvaluetimestamp,
               relntypeid
        FROM relnvalue
        JOIN relationship USING (relationshipid)
        WHERE relationship.deleted IS NULL
        GROUP BY relationshipid,
                 attributeid HAVING MAX(relnvaluetimestamp)
        AND MAX(relntimestamp) ) USING (relationshipid,
                                        attributeid,
                                        relnvaluetimestamp,
                                        relntypeid)
     WHERE relnvalue.deleted IS NULL
       AND relationshipid NOT IN
         ( SELECT relationshipid
          FROM
            (SELECT relationshipid,
                    aentreln.deleted AS ardeleted,
                    archentity.deleted AS adeleted
             FROM aentreln
             JOIN archentity USING (uuid)
             JOIN
               (SELECT uuid,
                       max(aenttimestamp) AS aenttimestamp
                FROM archentity
                GROUP BY uuid) USING (uuid,
                                      aenttimestamp)
             WHERE uuid = :uuid
             GROUP BY relationshipid,
                      uuid HAVING MAX (aentrelntimestamp) )
          WHERE ardeleted IS NULL
            AND adeleted IS NULL )
       AND relationshipid IN
         (SELECT relationshipid
          FROM
            (SELECT relationshipid, attributeid, MAX(RelnValueTimestamp) AS RelnValueTimestamp
             FROM relnvalue
             GROUP BY relationshipid,
                      attributeid HAVING MAX(RelnValueTimestamp))
          JOIN relnvalue USING (relationshipid,
                                attributeid,
                                RelnValueTimestamp)
          JOIN
            (SELECT relationshipid,
                    deleted
             FROM relationship
             GROUP BY relationshipid HAVING MAX(relntimestamp)) r USING (relationshipid)
          LEFT OUTER JOIN vocabulary USING (attributeid,
                                            vocabid)
          WHERE (freetext LIKE '%'||:query||'%'
                 OR vocabname LIKE '%'||:query||'%')
            AND r.deleted IS NULL
          GROUP BY relationshipid LIMIT :limit
          OFFSET :offset )
     ORDER BY relationshipid,
              attributename ASC)
GROUP BY relationshipid,
         attributeid;
EOF
    )
  end

  def self.get_vocab
    cleanup_query(<<EOF
select vocabname, vocabid from vocabulary where attributeid = ?
EOF
    )
  end

  def self.get_arch_entity_types
    cleanup_query(<<EOF
select aenttypename, aenttypeid from aenttype
EOF
    )
  end

  def self.get_relationship_types
    cleanup_query(<<EOF
select relntypename, relntypeid from relntype
EOF
    )
  end

  def self.get_current_version
    cleanup_query(<<EOF
select versionnum from version where ismerged = 1 order by versionnum desc
EOF
    )
  end

  def self.get_latest_version
    cleanup_query(<<EOF
select versionnum from version order by versionnum desc
EOF
    )
  end

  def self.insert_user_version
    cleanup_query(<<EOF
insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, ?, ?, 0 from version;
EOF
    )
  end

  def self.get_attributes_containing_vocab
    cleanup_query(<<EOF
    select attributeid, attributename
      from attributekey
      where attributeid in (select attributeid from vocabulary);
EOF
    )
  end

  def self.get_vocabs_for_attribute
    cleanup_query(<<EOF
    select attributeid, vocabid, vocabname
      from vocabulary
      where attributeid = ?;
EOF
    )
  end

  def self.update_attributes_vocab
    cleanup_query(<<EOF
    insert or replace into vocabulary (vocabid, attributeid, vocabname) VALUES(?, ?, ?);
EOF
    )
  end

  def self.merge_database(fromDB, version)
    cleanup_query(<<EOF
attach database '#{fromDB}' as import;

insert into archentity (
         uuid, aenttimestamp, userid, doi, aenttypeid, deleted, versionnum, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn)
  select uuid, aenttimestamp, userid, doi, aenttypeid, deleted, #{version}, isdirty, isdirtyreason, a.isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn
  from import.archentity
  left outer join (
		select uuid, i.aenttimestamp, 1 as isForked
		  from main.archentity m join  import.archentity i using (uuid, parenttimestamp)
		where m.aenttimestamp != i.aenttimestamp) a using (uuid, aenttimestamp)
  where uuid || aenttimestamp not in (select uuid || aenttimestamp from archentity);

insert into aentvalue (
         uuid, valuetimestamp, userid, attributeid, vocabid, freetext, measure, certainty, deleted, versionnum, isdirty, isdirtyreason, isforked, parenttimestamp)
  select uuid, valuetimestamp, userid, attributeid, vocabid, freetext, measure, certainty, deleted, #{version}, isdirty, isdirtyreason, a.isforked, parenttimestamp
  from import.aentvalue
  left outer join (
		select uuid, attributeid, i.valuetimestamp, 1 as isForked
		  from main.aentvalue m join  import.aentvalue i using (uuid, attributeid, parenttimestamp)
		where m.valuetimestamp != i.valuetimestamp) a using (uuid, attributeid, valuetimestamp)
  where uuid || valuetimestamp || attributeid not in (select uuid || valuetimestamp||attributeid from aentvalue);

insert into relationship (
         relationshipid, userid, relntimestamp, relntypeid, deleted, versionnum, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn)
  select relationshipid, userid, relntimestamp, relntypeid, deleted, #{version}, isdirty, isdirtyreason, a.isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn
  from import.relationship
	  left outer join (
		select relationshipid, i.relntimestamp, 1 as isForked
		  from main.relationship m join  import.relationship i using (relationshipid, parenttimestamp)
		where m.relntimestamp != i.relntimestamp) a using (relationshipid, relntimestamp)
  where relationshipid || relntimestamp not in (select relationshipid || relntimestamp from relationship);

insert into relnvalue (
         relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, freetext, certainty, deleted, versionnum, isdirty, isdirtyreason, isforked, parenttimestamp)
  select relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, freetext, certainty, deleted, #{version}, isdirty, isdirtyreason, a.isforked, parenttimestamp
  from import.relnvalue
  left outer join (
		select relationshipid, attributeid, i.relnvaluetimestamp, 1 as isForked
		  from main.relnvalue m join  import.relnvalue i using (relationshipid, attributeid, parenttimestamp)
		where m.relnvaluetimestamp != i.relnvaluetimestamp) a using (relationshipid, attributeid, relnvaluetimestamp)
  where relationshipid || relnvaluetimestamp || attributeid not in (select relationshipid || relnvaluetimestamp || attributeid from relnvalue);

insert into aentreln (
         uuid, relationshipid, userid, aentrelntimestamp, participatesverb, deleted, versionnum, isdirty, isdirtyreason, isforked, parenttimestamp)
  select uuid, relationshipid, userid, aentrelntimestamp, participatesverb, deleted, #{version}, isdirty, isdirtyreason, a.isforked, parenttimestamp
  from import.aentreln
	left outer join (
		select relationshipid, uuid, i.aentrelntimestamp, 1 as isForked
		  from main.aentreln m join  import.aentreln i using (relationshipid, uuid, parenttimestamp)
		where m.aentrelntimestamp != i.aentrelntimestamp) a using (relationshipid, uuid, aentrelntimestamp)
   where uuid || relationshipid || aentrelntimestamp not in (select uuid || relationshipid || aentrelntimestamp from aentreln);

update version set ismerged = 1 where versionnum = #{version};

detach database import;
EOF
    )
  end

  def self.create_app_database(toDB)
    cleanup_query(<<EOF
attach database "#{toDB}" as export;
create table export.user as select * from user;
create table export.aenttype as select * from aenttype;
create table export.attributekey as select * from attributekey;
create table export.vocabulary as select * from vocabulary;
create table export.relntype as select * from relntype;
create table export.idealaent as select * from idealaent;
create table export.idealreln as select * from idealreln;
create table export.archentity as select * from archentity;
create table export.aentvalue as select * from aentvalue;
create table export.relationship as select * from relationship;
create table export.relnvalue as select * from relnvalue;
create table export.aentreln as select * from aentreln;
EOF
    )
  end

  def self.create_app_database_from_version(toDB, version)
    cleanup_query(<<EOF
attach database "#{toDB}" as export;
create table export.archentity as select * from archentity where versionnum >= '#{version}';
create table export.aentvalue as select * from aentvalue where versionnum >= '#{version}';
create table export.relationship as select * from relationship where versionnum >= '#{version}';
create table export.relnvalue as select * from relnvalue where versionnum >= '#{version}';
create table export.aentreln as select * from aentreln where versionnum >= '#{version}';
create table export.vocabulary as select * from vocabulary;
create table export.user as select * from user;
detach database export;
EOF
    )
  end

  def self.get_arch_entity_type 
    cleanup_query(<<EOF
select aenttypename from archentity join aenttype using (aenttypeid) where uuid = ?;
EOF
    )
  end

  def self.get_relationship_type 
    cleanup_query(<<EOF
select relntypename from relationship join relntype using (relntypeid) where relationshipid = ?;
EOF
    )
  end

  def self.get_aent_value
    cleanup_query(<<EOF
SELECT uuid, attributeid, attributename, vocabid, vocabname, measure, freetext, certainty, valuetimestamp, userid, versionnum
    FROM aentvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
    WHERE deleted is NULL and uuid = ? and valuetimestamp = ? and attributeid = ?
 ORDER BY uuid, attributename ASC;
EOF
    )
  end

  def self.get_reln_value
    cleanup_query(<<EOF
SELECT relationshipid, attributeid, attributename, vocabid, vocabname, freetext, certainty, relnvaluetimestamp, userid, versionnum
    FROM relnvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   WHERE relnvalue.deleted is NULL and relationshipid = ? and relnvaluetimestamp = ? and attributeid = ?
ORDER BY relationshipid, attributename asc;
EOF
    )
  end

  def self.get_all_aent_values_for_version
    cleanup_query(<<EOF
SELECT uuid, valuetimestamp, attributeid
    FROM aentvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
    WHERE deleted is NULL and versionnum = ?
 ORDER BY uuid, attributename ASC;
EOF
    )
  end

  def self.get_all_reln_values_for_version
    cleanup_query(<<EOF
SELECT relationshipid, relnvaluetimestamp, attributeid
    FROM relnvalue
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
   WHERE relnvalue.deleted is NULL and versionnum = ?
ORDER BY relationshipid, attributename asc;
EOF
    )
  end

  def self.is_arch_entity_dirty
    cleanup_query(<<EOF
select sum(isdirty)
from (
  select isdirty, deleted
  from aentvalue join (
    select uuid, attributeid, max(valuetimestamp) as valuetimestamp
    from aentvalue
    where uuid = ? group by uuid, attributeid) using (uuid, attributeid, valuetimestamp)
  union
  select isdirty, deleted
  from archentity
  where uuid =  ?
  group by uuid
  having max(aenttimestamp))
where deleted is null;
EOF
    )
  end

    def self.is_relationship_dirty
    cleanup_query(<<EOF
select sum(isdirty)
from (
  select isdirty, deleted
  from relnvalue join (
    select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
    from relnvalue
    where relationshipid = ? group by relationshipid, attributeid) using (relationshipid, attributeid, relnvaluetimestamp)
  union
  select isdirty, deleted
  from relationship
  where relationshipid =  ?
  group by relationshipid
  having max(relntimestamp))
where deleted is null;
EOF
    )
  end

  def self.get_list_of_users
    cleanup_query(<<EOF
    select userid, fname, lname from user;
EOF
    )
  end

  def self.update_list_of_users
    cleanup_query(<<EOF
    insert into user (userid, fname, lname) values (?,?,?);
EOF
    )
  end

  def self.is_arch_entity_forked
    cleanup_query(<<EOF
    select count(isforked) from archentity where uuid = ?;
EOF
    )
  end

  def self.is_aentvalue_forked
    cleanup_query(<<EOF
    select count(isforked) from aentvalue where uuid = ?;
EOF
    )
  end

  def self.is_relationship_forked
    cleanup_query(<<EOF
    select count(isforked) from relationship where relationshipid = ?;
EOF
    )
  end

  def self.is_relnvalue_forked
    cleanup_query(<<EOF
    select count(isforked) from relnvalue where relationshipid = ?;
EOF
    )
  end

  def self.clear_arch_ent_fork
    cleanup_query(<<EOF
    update archentity set isforked = NULL where uuid = ?;
EOF
    )
  end

  def self.clear_aentvalue_fork
    cleanup_query(<<EOF
    update aentvalue set isforked = NULL where uuid = ?;
EOF
    )
  end

  def self.clear_rel_fork
    cleanup_query(<<EOF
    update relationship set isforked = NULL where relationshipid = ?;
EOF
    )
  end

  def self.clear_relnvalue_fork
    cleanup_query(<<EOF
    update relnvalue set isforked = NULL where relationshipid = ?;
EOF
    )
  end

  private

  def self.cleanup_query(query)
    query.gsub("\n", " ").gsub("\t", "")
  end

end