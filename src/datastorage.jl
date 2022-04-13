export DataStorage, filelist

using DataFrames

mutable struct DataStorage
    basepath::String
    db::SQLite.DB
    openedfiles::Dict{String, HDF5.File}

    DataStorage(basepath) = new(
        basepath,
        SQLite.DB(joinpath(basepath, "index.db")),
        Dict{String, HDF5.File}(),
    )
end

function files_in_range(ds::DataStorage, t0::TTEpoch{T}, t1::TTEpoch{T}) where {T}
    files = SQLite.DBInterface.execute(
        ds.db,
        """
                SELECT path, size_in_bytes, first_sample, last_sample
                FROM files
                WHERE ((:query_start >= first_sample) AND (:query_start <= last_sample))
                   OR ((:query_end >= first_sample) AND (:query_end <= last_sample))
                   OR ((:query_start <= first_sample) AND (:query_end >= last_sample))
                ORDER BY first_sample
            """,
        Dict(
            :query_start => tofloat(t0),
            :query_end => tofloat(t1),
        ),
    ) |> DataFrame

    files.path
end

function files_in_range(db, t0::AbstractFloat, t1::AbstractFloat) where {T}
    files_in_range(
        db,
        TTEpoch(t0 * days, origin = :modified_julian),
        TTEpoch(t1 * days, origin = :modified_julian),
    )
end

function files_in_range(db, t0::AstroPeriod{T, U}, t1::AstroPeriod{T, U}) where {T, U}
    files_in_range(
        db,
        TTEpoch(t0),
        TTEpoch(t1),
    )
end
