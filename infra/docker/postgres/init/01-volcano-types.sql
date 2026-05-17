-- Seeded into the volcanodemo database on first container start.
-- Source for the volcano-type lookup that the Data Virtualization demo
-- joins to via PolyBase ODBC from SQL Server 2025 on Linux.

CREATE TABLE volcano_type (
    type        VARCHAR(100) PRIMARY KEY,
    description VARCHAR(2000) NOT NULL
);

INSERT INTO volcano_type (type, description) VALUES
    ('Stratovolcano',
     'A tall, conical volcano built up by many alternating layers of hardened lava, tephra, pumice, and volcanic ash. Typically produces explosive eruptions.'),
    ('Shield',
     'A wide, gently sloped volcano formed by the eruption of fluid, low-viscosity basaltic lava that travels long distances before solidifying.'),
    ('Caldera',
     'A large basin-shaped depression formed when a volcano collapses into a partially emptied magma chamber after a major explosive eruption.'),
    ('Cinder cone',
     'A steep, conical hill of loose pyroclastic fragments that has built up around a single volcanic vent.'),
    ('Lava dome',
     'A roughly circular mound-shaped protrusion resulting from the slow extrusion of viscous lava from a volcanic vent.'),
    ('Pyroclastic shield',
     'A shield-like volcano built primarily from pyroclastic material rather than fluid lava flows.'),
    ('Submarine',
     'A volcanic vent or fissure that erupts beneath the surface of the ocean, often forming seamounts or new islands.'),
    ('Complex',
     'A volcanic landform composed of two or more distinct edifices, often with a mix of structural types and eruptive styles.'),
    ('Compound',
     'A volcano consisting of multiple coalesced cones, vents, or lava domes that have grown together over time.'),
    ('Maar',
     'A broad, low-relief volcanic crater caused by a phreatomagmatic eruption — an explosion produced when groundwater contacts hot magma.'),
    ('Tuff cone',
     'A monogenetic volcanic cone formed by hydromagmatic eruptions, composed of compacted volcanic ash (tuff).'),
    ('Tuff ring',
     'A wide, low-rimmed volcanic crater formed by short-lived explosive interactions between magma and shallow groundwater.'),
    ('Fissure vent',
     'A linear volcanic vent through which lava erupts, usually without significant explosive activity, often producing extensive lava flows.'),
    ('Subglacial',
     'A volcano formed under a glacier or ice sheet, often producing distinctive flat-topped (table mountain or tuya) features when the ice melts.'),
    ('Volcanic field',
     'A region containing many small monogenetic volcanic vents formed during one or more eruptive episodes.'),
    ('Crater rows',
     'A line of small volcanic craters or vents formed along an underlying fissure.'),
    ('Pyroclastic cone',
     'A volcanic cone built from explosively ejected fragments such as ash, lapilli, and bombs.'),
    ('Lava cone',
     'A small, steep-sided cone built almost entirely from successive lava flows rather than pyroclastic material.'),
    ('Somma volcano',
     'A volcano with a partially collapsed older edifice (the somma) surrounding a newer central cone.');
