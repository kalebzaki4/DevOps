/** @file
 * VM - The Virtual Machine, data.
 */

/*
 * Copyright (C) 2006-2024 Oracle and/or its affiliates.
 *
 * This file is part of VirtualBox base platform packages, as
 * available from https://www.virtualbox.org.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, in version 3 of the
 * License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses>.
 *
 * The contents of this file may alternatively be used under the terms
 * of the Common Development and Distribution License Version 1.0
 * (CDDL), a copy of it is provided in the "COPYING.CDDL" file included
 * in the VirtualBox distribution, in which case the provisions of the
 * CDDL are applicable instead of those of the GPL.
 *
 * You may elect to license modified versions of this file under the
 * terms and conditions of either the GPL or the CDDL or both.
 *
 * SPDX-License-Identifier: GPL-3.0-only OR CDDL-1.0
 */








#pragma D  depends_on library vbox-types.d
#pragma D  depends_on library CPUMInternal.d





/** @defgroup grp_vm    The Virtual Machine
 * @ingroup grp_vmm
 * @{
 */

/**
 * The state of a Virtual CPU.
 *
 * The basic state indicated here is whether the CPU has been started or not. In
 * addition, there are sub-states when started for assisting scheduling (GVMM
 * mostly).
 *
 * The transition out of the STOPPED state is done by a vmR3PowerOn.
 * The transition back to the STOPPED state is done by vmR3PowerOff.
 *
 * (Alternatively we could let vmR3PowerOn start CPU 0 only and let the SPIP
 * handling switch on the other CPUs. Then vmR3Reset would stop all but CPU 0.)
 */
typedef enum VMCPUSTATE
{
    /** The customary invalid zero. */
    VMCPUSTATE_INVALID = 0,

    /** Virtual CPU has not yet been started.  */
    VMCPUSTATE_STOPPED,

    /** CPU started. */
    VMCPUSTATE_STARTED,
    /** CPU started in HM context. */
    VMCPUSTATE_STARTED_HM,
    /** Executing guest code and can be poked (RC or STI bits of HM). */
    VMCPUSTATE_STARTED_EXEC,
    /** Executing guest code using NEM. */
    VMCPUSTATE_STARTED_EXEC_NEM,
    VMCPUSTATE_STARTED_EXEC_NEM_WAIT,
    VMCPUSTATE_STARTED_EXEC_NEM_CANCELED,
    /** Halted. */
    VMCPUSTATE_STARTED_HALTED,

    /** The end of valid virtual CPU states. */
    VMCPUSTATE_END,

    /** Ensure 32-bit type. */
    VMCPUSTATE_32BIT_HACK = 0x7fffffff
} VMCPUSTATE;

/** Enables 64-bit FFs. */



/**
 * The cross context virtual CPU structure.
 *
 * Run 'kmk run-struct-tests' (from src/VBox/VMM if you like) after updating!
 */
typedef struct VMCPU
{
    /** @name Volatile per-cpu data.
     * @{ */
    /** Per CPU forced action.
     * See the VMCPU_FF_* \#defines. Updated atomically. */

    uint64_t volatile       fLocalForcedActions;

    /** The CPU state. */
    VMCPUSTATE volatile     enmState;


    /** Padding up to 64 bytes. */
    uint8_t                 abAlignment0[64 - 12];

    /** @} */

    /** IEM part.
     * @remarks This comes first as it allows the use of 8-bit immediates for the
     *          first 64 bytes of the structure, reducing code size a wee bit. */

    union VMCPUUNIONIEMSTUB

    {

        uint8_t             padding[  129984    /* The common base size. */

                                    + 32768     /* For 256 entries per TLBs. */

        ]; /* multiple of 64 */
    } iem;

    /** @name Static per-cpu data.
     * (Putting this after IEM, hoping that it's less frequently used than it.)
     * @{ */
    /** Ring-3 Host Context VM Pointer. */
    PVMR3                   pVMR3;
    /** Ring-0 Host Context VM Pointer, currently used by VTG/dtrace. */
    RTR0PTR                 pVCpuR0ForVtg;
    /** Raw-mode Context VM Pointer. */
    uint32_t                pVMRC;
    /** Padding for new raw-mode (long mode).   */
    uint32_t                pVMRCPadding;
    /** Pointer to the ring-3 UVMCPU structure. */
    PUVMCPU                 pUVCpu;
    /** The native thread handle. */
    RTNATIVETHREAD          hNativeThread;
    /** The native R0 thread handle. (different from the R3 handle!) */
    RTNATIVETHREAD          hNativeThreadR0;
    /** The IPRT thread handle (for VMMDevTesting). */
    RTTHREAD                hThread;
    /** The CPU ID.
     * This is the index into the VM::aCpu array. */

    VMCPUID                 idCpuUnsafe;


    /** Align the structures below bit on a 64-byte boundary and make sure it starts
     * at the same offset in both 64-bit and 32-bit builds.
     *
     * @remarks The alignments of the members that are larger than 48 bytes should be
     *          64-byte for cache line reasons. structs containing small amounts of
     *          data could be lumped together at the end with a < 64 byte padding
     *          following it (to grow into and align the struct size).
     */
    uint8_t                 abAlignment1[64 - 6 * (64 == 32 ? 4 : 8) - 8 - 4];
    /** @} */

    /** HM part. */
    union VMCPUUNIONHM
    {

        uint8_t             padding[9984];      /* multiple of 64 */
    } hm;

    /** NEM part. */
    union VMCPUUNIONNEM
    {

        uint8_t             padding[4608];      /* multiple of 64 */
    } nem;

    /** TRPM part. */
    union VMCPUUNIONTRPM
    {

        uint8_t             padding[128];       /* multiple of 64 */
    } trpm;

    /** TM part. */
    union VMCPUUNIONTM
    {

        uint8_t             padding[5760];      /* multiple of 64 */
    } tm;

    /** VMM part. */
    union VMCPUUNIONVMM
    {

        uint8_t             padding[9536];       /* multiple of 64 */
    } vmm;

    /** PDM part. */
    union VMCPUUNIONPDM
    {

        uint8_t             padding[256];       /* multiple of 64 */
    } pdm;

    /** IOM part. */
    union VMCPUUNIONIOM
    {

        uint8_t             padding[512];       /* multiple of 64 */
    } iom;

    /** DBGF part.
     * @todo Combine this with other tiny structures. */
    union VMCPUUNIONDBGF
    {

        uint8_t             padding[512];       /* multiple of 64 */
    } dbgf;

    /** GIM part. */
    union VMCPUUNIONGIM
    {

        uint8_t             padding[512];       /* multiple of 64 */
    } gim;


    /** APIC part. */
    union VMCPUUNIONAPIC
    {

        uint8_t             padding[3840];      /* multiple of 64 */
    } apic;


    /*
     * Some less frequently used global members that doesn't need to take up
     * precious space at the head of the structure.
     */

    /** Trace groups enable flags.  */
    uint32_t                fTraceGroups;                           /* 64 / 44 */
    /** Number of collisions hashing the ring-0 EMT handle. */
    uint8_t                 cEmtHashCollisions;
    uint8_t                 abAdHoc[3];
    /** Profiling samples for use by ad hoc profiling. */
    STAMPROFILEADV          aStatAdHoc[8];                          /* size: 40*8 = 320 */

    /** Align the following members on page boundary. */
    uint8_t                 abAlignment2[1848];

    /** PGM part. */
    union VMCPUUNIONPGM
    {

        uint8_t             padding[36864];     /* multiple of 4096 */
    } pgm;

    /** CPUM part. */
    union VMCPUUNIONCPUM
    {

        struct CPUMCPU      s;


        uint8_t             padding[102400];    /* multiple of 4096 */
    } cpum;

    /** EM part. */
    union VMCPUUNIONEM
    {

        uint8_t             padding[40960];     /* multiple of 4096 */
    } em;
    uint8_t abPadding[12288];
} VMCPU;





/**
 * Helper that HM and NEM uses for safely modifying VM::bMainExecutionEngine.
 *
 * ONLY HM and NEM MAY USE THIS!
 *
 * @param   a_pVM       The cross context VM structure.
 * @param   a_bValue    The new value.
 * @internal
 */


/**
 * Checks whether iem-executes-all-mode is used.
 *
 * @retval  true if IEM is used.
 * @retval  false if not.
 *
 * @param   a_pVM       The cross context VM structure.
 * @sa      VM_IS_HM_OR_NEM_ENABLED, VM_IS_HM_ENABLED, VM_IS_NEM_ENABLED.
 * @internal
 */


/**
 * Checks whether HM (VT-x/AMD-V) or NEM is being used by this VM.
 *
 * @retval  true if either is used.
 * @retval  false if software virtualization (raw-mode) is used.
 *
 * @param   a_pVM       The cross context VM structure.
 * @sa      VM_IS_EXEC_ENGINE_IEM, VM_IS_HM_ENABLED, VM_IS_NEM_ENABLED.
 * @internal
 */


/**
 * Checks whether HM is being used by this VM.
 *
 * @retval  true if HM (VT-x/AMD-v) is used.
 * @retval  false if not.
 *
 * @param   a_pVM       The cross context VM structure.
 * @sa      VM_IS_NEM_ENABLED, VM_IS_EXEC_ENGINE_IEM, VM_IS_HM_OR_NEM_ENABLED.
 * @internal
 */


/**
 * Checks whether NEM is being used by this VM.
 *
 * @retval  true if a native hypervisor API is used.
 * @retval  false if not.
 *
 * @param   a_pVM       The cross context VM structure.
 * @sa      VM_IS_HM_ENABLED, VM_IS_EXEC_ENGINE_IEM, VM_IS_HM_OR_NEM_ENABLED.
 * @internal
 */



/**
 * The cross context VM structure.
 *
 * It contains all the VM data which have to be available in all contexts.
 * Even if it contains all the data the idea is to use APIs not to modify all
 * the members all around the place.  Therefore we make use of unions to hide
 * everything which isn't local to the current source module.  This means we'll
 * have to pay a little bit of attention when adding new members to structures
 * in the unions and make sure to keep the padding sizes up to date.
 *
 * Run 'kmk run-struct-tests' (from src/VBox/VMM if you like) after updating!
 */
typedef struct VM
{
    /** The state of the VM.
     * This field is read only to everyone except the VM and EM. */
    VMSTATE volatile            enmVMState;
    /** Forced action flags.
     * See the VM_FF_* \#defines. Updated atomically.
     */
    volatile uint32_t           fGlobalForcedActions;
    /** Pointer to the array of page descriptors for the VM structure allocation. */
    RTR3PTR         paVMPagesR3;
    /** Session handle. For use when calling SUPR0 APIs. */

    PSUPDRVSESSION              pSessionUnsafe;

    /** Pointer to the ring-3 VM structure. */
    PUVM                        pUVM;
    /** Ring-3 Host Context VM Pointer. */

    RTR3PTR      pVMR3Unsafe;

    /** Ring-0 Host Context VM pointer for making ring-0 calls. */
    struct VM *       pVMR0ForCall;
    /** Raw-mode Context VM Pointer. */
    uint32_t                    pVMRC;
    /** Padding for new raw-mode (long mode).   */
    uint32_t                    pVMRCPadding;

    /** The GVM VM handle. Only the GVM should modify this field. */

    uint32_t                    hSelfUnsafe;

    /** Number of virtual CPUs. */

    uint32_t                    cCpusUnsafe;

    /** CPU excution cap (1-100) */
    uint32_t                    uCpuExecutionCap;

    /** Size of the VM structure. */
    uint32_t                    cbSelf;
    /** Size of the VMCPU structure. */
    uint32_t                    cbVCpu;
    /** Structure version number (TBD). */
    uint32_t                    uStructVersion;

    /** @name Various items that are frequently accessed.
     * @{ */
    /** The main execution engine, VM_EXEC_ENGINE_XXX.
     * This is set early during vmR3InitRing3 by HM or NEM.  */
    uint8_t const               bMainExecutionEngine;

    /** Hardware VM support is available and enabled.
     * Determined very early during init.
     * This is placed here for performance reasons.
     * @todo obsoleted by bMainExecutionEngine, eliminate. */
    uint8_t                        fHMEnabled;
    /** @} */

    /** Alignment padding. */
    uint8_t                     uPadding1[6];

    /** @name Debugging
     * @{ */
    /** Ring-3 Host Context VM Pointer. */
    RTR3PTR       hTraceBufR3;
    /** Ring-0 Host Context VM Pointer. */
    RTTRACEBUF        hTraceBufR0;
    /** @} */

    /** Max EMT hash lookup collisions (in GVMM). */
    uint8_t                     cMaxEmtHashCollisions;

    /** Padding - the unions must be aligned on a 64 bytes boundary. */
    uint8_t                     abAlignment3[64 == 64 ? 23 : 51];

    /** CPUM part. */
    union
    {

        struct CPUM s;


        /** @todo this is rather bloated because of static MSR range allocation.
         *        Probably a good idea to move it to a separate R0 allocation... */
        uint8_t     padding[8832 + 128*8192 + 0x1d00]; /* multiple of 64 */
    } cpum;

    /** PGM part.
     * @note Aligned on 16384 boundrary for zero and mmio page storage. */
    union
    {

        uint8_t     padding[129728];     /* multiple of 64 */
    } pgm;

    /** VMM part. */
    union
    {

        uint8_t     padding[1600];      /* multiple of 64 */
    } vmm;

    /** HM part. */
    union
    {

        uint8_t     padding[5504];      /* multiple of 64 */
    } hm;

    /** TRPM part. */
    union
    {

        uint8_t     padding[2048];      /* multiple of 64 */
    } trpm;

    /** SELM part. */
    union
    {

        uint8_t     padding[768];       /* multiple of 64 */
    } selm;

    /** MM part. */
    union
    {

        uint8_t     padding[192];       /* multiple of 64 */
    } mm;

    /** PDM part. */
    union
    {

        uint8_t     padding[22528];     /* multiple of 64 */
    } pdm;

    /** IOM part. */
    union
    {

        uint8_t     padding[1152];      /* multiple of 64 */
    } iom;

    /** EM part. */
    union
    {

        uint8_t     padding[256];       /* multiple of 64 */
    } em;

    /** NEM part. */
    union
    {

        uint8_t     padding[4608];       /* multiple of 64 */
    } nem;

    /** TM part. */
    union
    {

        uint8_t     padding[10112];      /* multiple of 64 */
    } tm;

    /** DBGF part. */
    union
    {


        uint8_t     padding[2432];      /* multiple of 64 */
    } dbgf;

    /** SSM part. */
    union
    {

        uint8_t     padding[128];       /* multiple of 64 */
    } ssm;

    union
    {

        uint8_t     padding[448];       /* multiple of 64 */
    } gim;


    union
    {

        uint8_t     padding[128];       /* multiple of 8 */
    } apic;


    /* ---- begin small stuff ---- */

    /** VM part. */
    union
    {

        uint8_t     padding[32];        /* multiple of 8 */
    } vm;

    /** CFGM part. */
    union
    {

        uint8_t     padding[8];         /* multiple of 8 */
    } cfgm;

    /** IEM part. */
    union
    {

        uint8_t     padding[16];         /* multiple of 8 */
    } iem;

    /** Statistics for ring-0 only components. */
    struct
    {
        /** GMMR0 stats. */
        struct
        {
            /** Chunk TLB hits. */
            uint64_t    cChunkTlbHits;
            /** Chunk TLB misses. */
            uint64_t    cChunkTlbMisses;
        } gmm;
        uint64_t    au64Padding[6];     /* probably more comming here... */
    } R0Stats;

    union
    {

        uint8_t     padding[8];         /* multiple of 8 */
    } gcm;

    /** Padding for aligning the structure size on a page boundrary. */
    uint8_t         abAlignment2[0x3A00 - sizeof(PVMCPUR3) * VMM_MAX_CPU_COUNT];

    /* ---- end small stuff ---- */

    /** Array of VMCPU ring-3 pointers. */
    PVMCPUR3        apCpusR3[VMM_MAX_CPU_COUNT];

    /* This point is aligned on a 16384 boundrary (for arm64 purposes). */
} VM;





/** @} */



