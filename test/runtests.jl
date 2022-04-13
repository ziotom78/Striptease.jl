using AstroTime
import SQLite
import HDF5

using Striptease
using Test

function setup_test_database()
    dbpath = mktempdir()
    db = SQLite.DB(joinpath(dbpath, "index.db"))
    SQLite.execute(
        db,
        """
CREATE TABLE files(
    path TEXT,
    size_in_bytes NUMBER,
    first_sample REAL,
    last_sample REAL
);
CREATE TABLE tags(
    id INTEGER PRIMARY KEY,
    mjd_start REAL,
    mjd_end REAL,
    tag TEXT,
    start_comment TEXT,
    end_comment TEXT
);
""",
    )

    dbpath, db
end


function create_mock_files(dbpath, db)
    hktime1 = [TTEpoch(t * days, origin = :modified_julian)
               for t in (0.0, 1.0)]
    scitime1 = [TTEpoch(t * days, origin = :modified_julian)
                for t in (0.0, 0.5, 1.0)]

    hktime2 = [TTEpoch(t * days, origin = :modified_julian)
               for t in (10.0, 11.0)]
    scitime2 = [TTEpoch(t * days, origin = :modified_julian)
                for t in (10.0, 10.5, 11.0)]

    filepaths = String[]
    for (filename, hktime, scitime) in zip(
        ("file1.h5", "file2.h5"),
        (hktime1, hktime2),
        (scitime1, scitime2),
    )
        cur_filepath = joinpath(dbpath, filename)
        HDF5.h5open(cur_filepath, "w") do fid
            hdf5_create_random_data(fid, hktime, scitime)
        end
        push!(filepaths, cur_filepath)
    end

    SQLite.execute(
        db,
        """
INSERT INTO files VALUES (:path, :size, :first_sample, :last_sample)
        """,
        (
            path = filepaths[1],
            size = filesize(filepaths[1]),
            first_sample = modified_julian(scitime1[1]) |> value,
            last_sample = modified_julian(scitime1[end]) |> value,
        ),
    )

    SQLite.execute(
        db,
        """
INSERT INTO files VALUES (:path, :size, :first_sample, :last_sample)
        """,
        (
            path = filepaths[2],
            size = filesize(filepaths[2]),
            first_sample = modified_julian(scitime2[1]) |> value,
            last_sample = modified_julian(scitime2[end]) |> value,
        ),
    )
end

                            
@testset "conventions" begin
    res = polarimeter_list()
    @test length(res) == 55

    res = polarimeter_list(boards=[:R], qband=true, wband=false)
    @test length(res) == 7

    res = polarimeter_list(boards=[:G], qband=false, wband=true)
    @test length(res) == 1
    
    res = polarimeter_list(boards=[:I], qband=false, wband=true)
    @test length(res) == 0

    res = polarimeter_list(boards=[:R, :I], qband=false, wband=true)
    @test length(res) == 1

    res = polarimeter_list(boards=[:B, :V], qband=true, wband=true)
    @test length(res) == 16

    @test length(BOARD_NAMES) == 7

    @test length(BOARD_TO_W_BAND_POL |> keys) == 6

    @test length(W_BAND_POL_TO_BOARD |> keys) == 6
end

removedirs(l) = [basename(x) for x in l]

@testset "database" begin
    dbpath, db = setup_test_database()
    create_mock_files(dbpath, db)

    ds = DataStorage(dbpath)
    @test ["file1.h5"] == files_in_range(ds, -0.5, 0.5) |> removedirs
    @test ["file1.h5"] == files_in_range(ds, 0.5, 0.8) |> removedirs
    @test ["file1.h5"] == files_in_range(ds, 0.5, 1.5) |> removedirs
    @test ["file1.h5"] == files_in_range(ds, -0.5, 1.5) |> removedirs

    @test ["file2.h5"] == files_in_range(ds, 9.5, 10.5) |> removedirs
    @test ["file2.h5"] == files_in_range(ds, 10.5, 10.8) |> removedirs
    @test ["file2.h5"] == files_in_range(ds, 10.5, 11.5) |> removedirs
    @test ["file2.h5"] == files_in_range(ds, 9.5, 11.5) |> removedirs

    @test [] == files_in_range(ds, -5.5, -4.5)
    @test [] == files_in_range(ds, 4.5, 5.5)
    @test [] == files_in_range(ds, 14.5, 15.5)

    @test ["file1.h5", "file2.h5"] == files_in_range(ds, -0.5, 15.0) |> removedirs
    @test ["file1.h5", "file2.h5"] == files_in_range(ds, 0.5, 10.5) |> removedirs
end
