import HDF5
using AstroTime

export hdf5_create_random_data, read_polarimeter_data, files_in_range

const BOARD_BIAS_HK_NAMES = [
    "CAL_RCL", "CAL_STO", "CPUID", "CPU_TEMP", "CW_KEY[4FFB]",
    "CW_POL", "DAC_STAT", "DEVSZ", "FWID", "FWREV",
    "HK_CONV", "HK_COUNT", "HK_DATA", "HK_MUX",
    "HK_PGA", "HK_POL", "HK_SCAN",
    "ID0_DIV", "ID0_MUL", "ID0_SUM",
    "ID1_DIV", "ID1_MUL", "ID1_SUM",
    "ID2_DIV", "ID2_MUL", "ID2_SUM",
    "ID3_DIV", "ID3_MUL", "ID3_SUM",
    "ID4_DIV", "ID4_MUL", "ID4_SUM",
    "ID5_DIV", "ID5_MUL", "ID5_SUM",
    "IG0_DIV", "IG0_MUL", "IG0_SUM",
    "IG1_DIV", "IG1_MUL", "IG1_SUM",
    "IG2_DIV", "IG2_MUL", "IG2_SUM",
    "IG3_DIV", "IG3_MUL", "IG3_SUM",
    "IG4A_DIV", "IG4A_MUL", "IG4A_SUM",
    "IG4_DIV", "IG4_MUL", "IG4_SUM",
    "IG5A_DIV", "IG5A_MUL",
    "IG5_DIV", "IG5_MUL", "IG5_SUM",
    "IP0_DIV", "IP0_MUL", "IP0_SUM",
    "IP1_DIV", "IP1_MUL", "IP1_SUM",
    "IP2_DIV", "IP2_MUL", "IP2_SUM",
    "IP3_DIV", "IP3_MUL", "IP3_SUM",
    "PCBID", "PHASE_SRC", "POL_RCL", "POL_STO",
    "PWR_PAT", "PWR_STAT", "REVID",
    "RFS0_FLG", "RFS1_FLG", "RFS2_FLG", "RFS3_FLG", "RFS4_FLG",
    "START_BIAS", "START_PWR", "START_RCL_DIS", "SYS_RCL", "SYS_STO",
    "UID0", "UID1", "UID2", "UID3", "UID4", "UID5",
    "VD0_DIV", "VD0_MUL", "VD0_SUM",
    "VD1_DIV", "VD1_MUL", "VD1_SUM",
    "VD2_DIV", "VD2_MUL", "VD2_SUM",
    "VD3_DIV", "VD3_MUL", "VD3_SUM",
    "VD4_DIV", "VD4_MUL", "VD4_SUM",
    "VD5_DIV", "VD5_MUL", "VD5_SUM",
    "VG0_DIV", "VG0_MUL", "VG0_SUM",
    "VG1_DIV", "VG1_MUL", "VG1_SUM",
    "VG2_DIV", "VG2_MUL", "VG2_SUM",
    "VG3_DIV", "VG3_MUL", "VG3_SUM",
    "VG4A_DIV", "VG4A_MUL", "VG4A_SUM",
    "VG4_DIV", "VG4_MUL", "VG4_SUM",
    "VG5A_DIV", "VG5A_MUL", "VG5A_SUM", "VG5_DIV",
    "VG5_MUL", "VG5_SUM",
    "VP0_DIV", "VP0_MUL", "VP0_SUM",
    "VP1_DIV", "VP1_MUL", "VP1_SUM",
    "VP2_DIV", "VP2_MUL", "VP2_SUM",
    "VP3_DIV", "VP3_MUL", "VP3_SUM",
]

const BOARD_DAQ_HK_NAMES = [
    "BLK_D", "CLK_REF", "CPUID", "CPU_TEMP", "DEVSZ",
    "FWID", "FWREV", "HK_DIS", "PCBID",
    "POL_RCL", "POL_STO", "PWR_PAT", "PWR_STAT", "REVID",
    "RFS0_FLG", "RFS1_FLG", "RFS2_FLG", "RFS3_FLG", "RFS4_FLG",
    "START_BIAS", "START_PWR", "START_RCL_DIS",
    "SYS_RCL", "SYS_STO",
    "UID0", "UID1", "UID2", "UID3", "UID4", "UID5",
]

const POL_BIAS_HK_NAMES = [
    "DAC_REF", "IA_DIV", "IA_MUL", "IA_PGA", "IA_SUM",
    "ID0_DIV", "ID0_HK", "ID0_MUL", "ID0_SET", "ID0_SUM",
    "ID1_DIV", "ID1_HK", "ID1_MUL", "ID1_SET", "ID1_SUM",
    "ID2_DIV", "ID2_HK", "ID2_MUL", "ID2_SET", "ID2_SUM",
    "ID3_DIV", "ID3_HK", "ID3_MUL", "ID3_SET", "ID3_SUM",
    "ID4_DIV", "ID4_HK", "ID4_MUL", "ID4_SET", "ID4_SUM",
    "ID5_DIV", "ID5_HK", "ID5_MUL", "ID5_SET", "ID5_SUM",
    "ID_DIV", "ID_MUL", "ID_PGA", "ID_SUM",
    "IG0_DIV", "IG0_HK", "IG0_MUL", "IG0_SUM",
    "IG1_DIV", "IG1_HK", "IG1_MUL", "IG1_SUM",
    "IG2_DIV", "IG2_HK", "IG2_MUL", "IG2_SUM",
    "IG3_DIV", "IG3_HK", "IG3_MUL", "IG3_SUM",
    "IG4A_DIV", "IG4A_HK", "IG4A_MUL", "IG4A_SUM",
    "IG4_DIV", "IG4_HK", "IG4_MUL", "IG4_SUM",
    "IG5A_DIV", "IG5A_HK", "IG5A_MUL", "IG5A_SUM",
    "IG5_DIV", "IG5_HK", "IG5_MUL", "IG5_SUM",
    "IG_DIV", "IG_MUL", "IG_PGA", "IG_SUM",
    "IP0_DIV", "IP0_MUL", "IP0_SUM", "IP1_DIV", "IP1_MUL",
    "IP1_SUM", "IP2_DIV", "IP2_MUL", "IP2_SUM",
    "IP3_DIV", "IP3_MUL", "IP3_SUM",
    "IPIN0_HK", "IPIN0_SET", "IPIN1_HK", "IPIN1_SET",
    "IPIN2_HK", "IPIN2_SET", "IPIN3_HK", "IPIN3_SET",
    "IP_DIV", "IP_MUL", "IP_PGA", "IP_SUM",
    "MEAS_ID", "PIN0_CON",
    "PIN1_CON", "PIN2_CON", "PIN3_CON",
    "POL_MODE", "POL_PWR",
    "RFB0_FLG", "RFB1_FLG", "RFB2_FLG", "RFB3_FLG", "RFB4_FLG",
    "SET_UPD0", "SET_UPD1",
    "VA_DIV", "VA_MUL", "VA_PGA", "VA_SUM",
    "VD0_DIV", "VD0_HK", "VD0_MUL", "VD0_SET", "VD0_SUM",
    "VD1_DIV", "VD1_HK", "VD1_MUL", "VD1_SET", "VD1_SUM",
    "VD2_DIV", "VD2_HK", "VD2_MUL", "VD2_SET", "VD2_SUM",
    "VD3_DIV", "VD3_HK", "VD3_MUL", "VD3_SET", "VD3_SUM",
    "VD4_DIV", "VD4_HK", "VD4_MUL", "VD4_SET", "VD4_SUM",
    "VD5_DIV", "VD5_HK", "VD5_MUL", "VD5_SET", "VD5_SUM",
    "VD_DIV", "VD_MUL", "VD_PGA", "VD_SUM",
    "VG0_DIV", "VG0_HK", "VG0_MUL", "VG0_SET", "VG0_SUM",
    "VG1_DIV", "VG1_HK", "VG1_MUL", "VG1_SET", "VG1_SUM",
    "VG2_DIV", "VG2_HK", "VG2_MUL", "VG2_SET", "VG2_SUM",
    "VG3_DIV", "VG3_HK", "VG3_MUL", "VG3_SET", "VG3_SUM",
    "VG4A_DIV", "VG4A_HK", "VG4A_MUL", "VG4A_SET", "VG4A_SUM",
    "VG4_DIV", "VG4_HK", "VG4_MUL", "VG4_SET", "VG4_SUM",
    "VG5A_DIV", "VG5A_HK", "VG5A_MUL", "VG5A_SET", "VG5A_SUM",
    "VG5_DIV", "VG5_HK", "VG5_MUL", "VG5_SET", "VG5_SUM",
    "VG_DIV", "VG_MUL", "VG_PGA", "VG_SUM",
    "VP0_DIV", "VP0_MUL", "VP0_SUM",
    "VP1_DIV", "VP1_MUL", "VP1_SUM",
    "VP2_DIV", "VP2_MUL", "VP2_SUM",
    "VP3_DIV", "VP3_MUL", "VP3_SUM",
    "VPIN0_HK", "VPIN0_SET",
    "VPIN1_HK", "VPIN1_SET",
    "VPIN2_HK", "VPIN2_SET",
    "VPIN3_HK", "VPIN3_SET",
    "VP_DIV", "VP_MUL", "VP_PGA", "VP_SUM",
]

const POL_DAQ_HK_NAMES = [
    "DAC_EN",
    "DET0_BIAS", "DET0_GAIN", "DET0_OFFS",
    "DET1_BIAS", "DET1_GAIN", "DET1_OFFS",
    "DET2_BIAS", "DET2_GAIN", "DET2_OFFS",
    "DET3_BIAS", "DET3_GAIN", "DET3_OFFS",
    "GAIN_EN", "PRE_EN", "RFP_FLAG",
]

struct Hdf5HkSample
    time::Float64
    value::Int16
end

struct Hdf5SciSample
    m_jd::Float64
    DEMQ1::Int32
    PWRQ1::UInt32
    DEMU1::Int32
    PWRU1::UInt32
    DEMU2::Int32
    PWRU2::UInt32
    DEMQ2::Int32
    PWRQ2::UInt32
    flag::UInt8
end

struct Hdf5Tag
    id:: UInt64
    mjd_start::Float64
    mjd_end::Float64
    tag::NTuple{32, UInt8}
    start_comment::NTuple{4096, UInt8}
    end_comment::NTuple{4096, UInt8}
end

function HDF5.datatype(::Type{T}) where T
    dtype = HDF5.API.h5t_create(HDF5.API.H5T_COMPOUND, sizeof(T))

    for i in 1:fieldcount(T)
        curtype = fieldtype(T, i)
        
        if curtype == Cstring
            str_dtype = HDF5.API.h5t_copy(HDF5.API.H5T_C_S1)
            HDF5.API.h5t_set_size(str_dtype, HDF5.API.H5T_VARIABLE)
            HDF5.API.h5t_set_cset(str_dtype, HDF5.API.H5T_CSET_UTF8)
            HDF5.API.h5t_insert(
                dtype,
                fieldname(T, i),
                fieldoffset(T, i),
                str_dtype,
            )
        elseif (curtype <: NTuple) && fieldtype(curtype, 1) == UInt8
            str_dtype = HDF5.API.h5t_copy(HDF5.API.H5T_C_S1)
            HDF5.API.h5t_set_size(str_dtype, sizeof(curtype))
            HDF5.API.h5t_set_cset(str_dtype, HDF5.API.H5T_CSET_UTF8)
            HDF5.API.h5t_set_strpad(str_dtype, HDF5.API.H5T_STR_NULLPAD)
            HDF5.API.h5t_insert(
                dtype,
                fieldname(T, i),
                fieldoffset(T, i),
                str_dtype,
            )
        else
            HDF5.API.h5t_insert(
                dtype,
                fieldname(T, i),
                fieldoffset(T, i),
                HDF5.datatype(curtype),
            )
        end
    end

    HDF5.Datatype(dtype)
end

function _create_hdf5_hk(group, names, times)
    for hk_param in names
        HDF5.create_dataset(
            group,
            hk_param,
            HDF5.datatype(Hdf5HkSample),
            HDF5.dataspace([
                Hdf5HkSample(
                    tofloat(t),
                    rand(fieldtype(Hdf5HkSample, 2)),
                ) for t in times
            ]),
        )
    end
end

string2ntuple(s::String, len) = ntuple(i -> i <= ncodeunits(s) ? codeunit(s, i) : UInt8(0), len)

function hdf5_create_random_data(fid::HDF5.File, hktime, scitime)
    for board_letter in BOARD_NAMES
        board_group_name = "BOARD_$(board_letter)"
        HDF5.create_group(fid, board_group_name)

        bias_group_name = "$(board_group_name)/BIAS"
        bias_group = HDF5.create_group(fid, bias_group_name)
        _create_hdf5_hk(bias_group, BOARD_BIAS_HK_NAMES, hktime)
        
        daq_group_name = "$(board_group_name)/DAQ"
        daq_group = HDF5.create_group(fid, daq_group_name)
        _create_hdf5_hk(daq_group, BOARD_DAQ_HK_NAMES, hktime)
    end

    HDF5.create_group(fid, "COMMANDS")
    HDF5.create_group(fid, "CRYO")
    HDF5.create_group(fid, "LOG")

    for polarimeter_name in polarimeter_list()
        pol_group_name = "POL_$(polarimeter_name)"
        pol_group = HDF5.create_group(fid, pol_group_name)

        bias_group_name = "$(pol_group_name)/BIAS"
        bias_group = HDF5.create_group(fid, bias_group_name)
        _create_hdf5_hk(bias_group, BOARD_BIAS_HK_NAMES, hktime)
        
        daq_group_name = "$(pol_group_name)/DAQ"
        daq_group = HDF5.create_group(fid, daq_group_name)
        _create_hdf5_hk(daq_group, BOARD_DAQ_HK_NAMES, hktime)

        HDF5.create_dataset(
            pol_group,
            "pol_data",
            HDF5.datatype(Hdf5SciSample),
            HDF5.dataspace([
                Hdf5SciSample(
                    tofloat(t),
                    rand(Int32),
                    rand(UInt32),
                    rand(Int32),
                    rand(UInt32),
                    rand(Int32),
                    rand(UInt32),
                    rand(Int32),
                    rand(UInt32),
                    rand(UInt8),
                ) for t in scitime
            ]),
        )
    end
    
    HDF5.create_group(fid, "POSITION")
    tags_group = HDF5.create_group(fid, "TAGS")
    dataspace = Hdf5Tag[
            Hdf5Tag(
                0,
                tofloat(scitime[1]),
                tofloat(scitime[end]),
                string2ntuple("test_tag", 32),
                string2ntuple("start_comment", 4096),
                string2ntuple("end_comment", 4096),
            ),
    ]

    taglist = Array{Hdf5Tag}(undef, 1)
    taglist[1] = Hdf5Tag(
        0,
        tofloat(scitime[1]),
        tofloat(scitime[end]),
        string2ntuple("test_tag", 32),
        string2ntuple("start_comment", 4096),
        string2ntuple("end_comment", 4096),
    )
    
    HDF5.create_dataset(
        tags_group,
        "tag_data",
        HDF5.datatype(Hdf5Tag),
        HDF5.dataspace(taglist)
    )
    
    HDF5.create_group(fid, "TIME_CORRELATION")

    HDF5.attributes(fid)["FIRST_SAMPLE"] = tofloat(scitime[1])
    HDF5.attributes(fid)["LAST_SAMPLE"] = tofloat(scitime[end])
end


function read_polarimeter_data(fid::HDF5.File, polarimeter::Symbol)
    group_name = "POL_$(polarimeter)/pol_data"
    data = read(fid[group_name])

    times = [TTEpoch(x.m_jd * days, origin = :modified_julian) for x in data]
    
    pwrdata = hcat(
        [x.PWRQ1 for x in data],
        [x.PWRQ2 for x in data],
        [x.PWRU1 for x in data],
        [x.PWRU2 for x in data],
    )
    
    demdata = hcat(
        [x.DEMQ1 for x in data],
        [x.DEMQ2 for x in data],
        [x.DEMU1 for x in data],
        [x.DEMU2 for x in data],
    )
    
    (time = times, pwrdata = pwrdata, demdata = demdata)
end
