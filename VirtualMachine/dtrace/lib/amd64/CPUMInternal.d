/* $Id: CPUMInternal.h 167060 2025-01-20 16:26:58Z bird $ */
/** @file
 * CPUM - Internal header file.
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
 * SPDX-License-Identifier: GPL-3.0-only
 */








#pragma D  depends_on library x86.d
#pragma D  depends_on library cpumctx.d
#pragma D  depends_on library cpum.d

/* Some fudging. */
typedef uint64_t STAMCOUNTER;





/** @defgroup grp_cpum_int   Internals
 * @ingroup grp_cpum
 * @internal
 * @{
 */

/** Use flags (CPUM::fUseFlags).
 * (Don't forget to sync this with CPUMInternal.mac !)
 * @note Was part of saved state (6.1 and earlier).
 * @{ */
/** Indicates that we've saved the host FPU, SSE, whatever state and that it
 * needs to be restored. */
inline uint32_t CPUM_USED_FPU_HOST = 1U << 0;

/** Indicates that we've loaded the guest FPU, SSE, whatever state and that it
 * needs to be saved.
 * @note Mirrored in CPUMCTX::fUsedFpuGuest for the HM switcher code. */
inline uint32_t CPUM_USED_FPU_GUEST = 1U << 10;

/** Used the guest FPU, SSE or such stuff since last we were in REM.
 * REM syncing is clearing this, lazy FPU is setting it. */
inline uint32_t CPUM_USED_FPU_SINCE_REM = 1U << 1;

/** The XMM state was manually restored. (AMD only) */
inline uint32_t CPUM_USED_MANUAL_XMM_RESTORE = 1U << 2;


/** Host OS is using SYSENTER and we must NULL the CS. */
inline uint32_t CPUM_USE_SYSENTER = 1U << 3;

/** Host OS is using SYSENTER and we must NULL the CS. */
inline uint32_t CPUM_USE_SYSCALL = 1U << 4;


/** Debug registers are used by host and that DR7 and DR6 must be saved and
 *  disabled when switching to raw-mode. */
inline uint32_t CPUM_USE_DEBUG_REGS_HOST = 1U << 5;

/** Records that we've saved the host DRx registers.
 * In ring-0 this means all (DR0-7), while in raw-mode context this means DR0-3
 * since DR6 and DR7 are covered by CPUM_USE_DEBUG_REGS_HOST. */
inline uint32_t CPUM_USED_DEBUG_REGS_HOST = 1U << 6;

/** Set to indicate that we should save host DR0-7 and load the hypervisor debug
 * registers in the raw-mode world switchers. (See CPUMRecalcHyperDRx.) */
inline uint32_t CPUM_USE_DEBUG_REGS_HYPER = 1U << 7;

/** Used in ring-0 to indicate that we have loaded the hypervisor debug
 * registers. */
inline uint32_t CPUM_USED_DEBUG_REGS_HYPER = 1U << 8;

/** Used in ring-0 to indicate that we have loaded the guest debug
 * registers (DR0-3 and maybe DR6) for direct use by the guest.
 * DR7 (and AMD-V DR6) are handled via the VMCB. */
inline uint32_t CPUM_USED_DEBUG_REGS_GUEST = 1U << 9;


/** Host CPU requires fxsave/fxrstor leaky bit handling. */
inline uint32_t CPUM_USE_FFXSR_LEAKY = 1U << 19;

/** Set if the VM supports long-mode. */
inline uint32_t CPUM_USE_SUPPORTS_LONGMODE = 1U << 20;

/** @} */


/** @name CPUM Saved State Version.
 * @{ */
/** The current saved state version.
 *  @todo When bumping to next version, add CPUMCTX::enmHwVirt and
 *        uMicrocodeRevision to the saved state. */

/** The saved state version with u32RestoreProcCtls2 for Nested Microsoft
 *  Hyper-V. */
inline uint8_t CPUM_SAVED_STATE_VERSION_HWVIRT_VMX_4 = 23;

/** The saved state version with more virtual VMCS fields (HLAT prefix size,
 *  PCONFIG-exiting bitmap, HLAT ptr, VM-exit ctls2) and a CPUMCTX field (VM-exit
 *  ctls2 MSR). */
inline uint8_t CPUM_SAVED_STATE_VERSION_HWVIRT_VMX_3 = 22;

/** The saved state version with PAE PDPEs added. */
inline uint8_t CPUM_SAVED_STATE_VERSION_PAE_PDPES = 21;

/** The saved state version with more virtual VMCS fields and CPUMCTX VMX fields. */
inline uint8_t CPUM_SAVED_STATE_VERSION_HWVIRT_VMX_2 = 20;

/** The saved state version including VMX hardware virtualization state. */
inline uint8_t CPUM_SAVED_STATE_VERSION_HWVIRT_VMX = 19;

/** The saved state version including SVM hardware virtualization state. */
inline uint8_t CPUM_SAVED_STATE_VERSION_HWVIRT_SVM = 18;

/** The saved state version including XSAVE state. */
inline uint8_t CPUM_SAVED_STATE_VERSION_XSAVE = 17;

/** The saved state version with good CPUID leaf count. */
inline uint8_t CPUM_SAVED_STATE_VERSION_GOOD_CPUID_COUNT = 16;

/** CPUID changes with explode forgetting to update the leaf count on
 * restore, resulting in garbage being saved restoring+saving old states). */
inline uint8_t CPUM_SAVED_STATE_VERSION_BAD_CPUID_COUNT = 15;

/** The saved state version before the CPUIDs changes. */
inline uint8_t CPUM_SAVED_STATE_VERSION_PUT_STRUCT = 14;

/** The saved state version before using SSMR3PutStruct. */
inline uint8_t CPUM_SAVED_STATE_VERSION_MEM = 13;

/** The saved state version before introducing the MSR size field. */
inline uint8_t CPUM_SAVED_STATE_VERSION_NO_MSR_SIZE = 12;

/** The saved state version of 3.2, 3.1 and 3.3 trunk before the hidden
 * selector register change (CPUM_CHANGED_HIDDEN_SEL_REGS_INVALID). */
inline uint8_t CPUM_SAVED_STATE_VERSION_VER3_2 = 11;

/** The saved state version of 3.0 and 3.1 trunk before the teleportation
 * changes. */
inline uint8_t CPUM_SAVED_STATE_VERSION_VER3_0 = 10;

/** The saved state version for the 2.1 trunk before the MSR changes. */
inline uint8_t CPUM_SAVED_STATE_VERSION_VER2_1_NOMSR = 9;

/** The saved state version of 2.0, used for backwards compatibility. */
inline uint8_t CPUM_SAVED_STATE_VERSION_VER2_0 = 8;

/** The saved state version of 1.6, used for backwards compatibility. */
inline uint8_t CPUM_SAVED_STATE_VERSION_VER1_6 = 6;

/** @} */


/** @name XSAVE limits.
 * @{ */
/** Max size we accept for the XSAVE area.
 * @see CPUMCTX::abXSave */

/* Min size we accept for the XSAVE area. */
inline uint16_t CPUM_MIN_XSAVE_AREA_SIZE = 0x240;

/** @} */


/**
 * CPU info
 */
typedef struct CPUMINFO
{
    /** The number of MSR ranges (CPUMMSRRANGE) in the array pointed to below. */
    uint32_t                    cMsrRanges;
    /** Mask applied to ECX before looking up the MSR for a RDMSR/WRMSR
     * instruction.  Older hardware has been observed to ignore higher bits. */
    uint32_t                    fMsrMask;

    /** MXCSR mask. */
    uint32_t                    fMxCsrMask;

    /** The number of CPUID leaves (CPUMCPUIDLEAF) in the array pointed to below. */
    uint32_t                    cCpuIdLeaves;
    /** The index of the first extended CPUID leaf in the array.
     *  Set to cCpuIdLeaves if none present. */
    uint32_t                    iFirstExtCpuIdLeaf;
    /** How to handle unknown CPUID leaves. */
    CPUMUNKNOWNCPUID            enmUnknownCpuIdMethod;
    /** For use with CPUMUNKNOWNCPUID_DEFAULTS (DB & VM),
     * CPUMUNKNOWNCPUID_LAST_STD_LEAF (VM) and CPUMUNKNOWNCPUID_LAST_STD_LEAF_WITH_ECX (VM). */
    CPUMCPUID                   DefCpuId;

    /** Scalable bus frequency used for reporting other frequencies. */
    uint64_t                    uScalableBusFreq;

    /** The microcode revision.
     * UINT32_MAX if the one from the CPU database entry is to be used.
     * @see /CPUM/GuestMicrocodeRevision in CFGM. */
    uint32_t                    uMicrocodeRevision;
    uint32_t                    uPadding;

    /** Pointer to the MSR ranges (for compatibility with old hyper heap code). */
    RTR3PTR    paMsrRangesR3;
    /** Pointer to the CPUID leaves (for compatibility with old hyper heap code). */
    RTR3PTR   paCpuIdLeavesR3;

    /** CPUID leaves. */
    CPUMCPUIDLEAF               aCpuIdLeaves[256];
    /** MSR ranges.
     * @todo This is insane, so might want to move this into a separate
     *       allocation.  The insanity is mainly for more recent AMD CPUs. */
    CPUMMSRRANGE                aMsrRanges[8192];
} CPUMINFO;
/** Pointer to a CPU info structure. */
typedef CPUMINFO *PCPUMINFO;
/** Pointer to a const CPU info structure. */
typedef CPUMINFO const *CPCPUMINFO;


/**
 * The saved host CPU state.
 */
typedef struct CPUMHOSTCTX
{
    /** The extended state (FPU/SSE/AVX/AVX-2/XXXX). Must be aligned on 64 bytes. */
    union /* no tag */
    {
        X86XSAVEAREA    XState;
        /** Byte view for simple indexing and space allocation.
         * @note Must match or exceed the size of CPUMCTX::abXState. */
        uint8_t         abXState[0x4000 - 0x300];
    } CPUM_UNION_NM(u);

    /** General purpose register, selectors, flags and more
     * @{ */
    /** General purpose register ++
     * { */
    /*uint64_t        rax; - scratch*/
    uint64_t        rbx;
    /*uint64_t        rcx; - scratch*/
    /*uint64_t        rdx; - scratch*/
    uint64_t        rdi;
    uint64_t        rsi;
    uint64_t        rbp;
    uint64_t        rsp;
    /*uint64_t        r8; - scratch*/
    /*uint64_t        r9; - scratch*/
    uint64_t        r10;
    uint64_t        r11;
    uint64_t        r12;
    uint64_t        r13;
    uint64_t        r14;
    uint64_t        r15;
    /*uint64_t        rip; - scratch*/
    uint64_t        rflags;
    /** @} */

    /** Selector registers
     * @{ */
    RTSEL           ss;
    RTSEL           ssPadding;
    RTSEL           gs;
    RTSEL           gsPadding;
    RTSEL           fs;
    RTSEL           fsPadding;
    RTSEL           es;
    RTSEL           esPadding;
    RTSEL           ds;
    RTSEL           dsPadding;
    RTSEL           cs;
    RTSEL           csPadding;
    /** @} */

    /** Control registers.
     * @{ */
    /** The CR0 FPU state in HM mode.  */
    uint64_t        cr0;
    /*uint64_t        cr2; - scratch*/
    uint64_t        cr3;
    uint64_t        cr4;
    uint64_t        cr8;
    /** @} */

    /** Debug registers.
     * @{ */
    uint64_t        dr0;
    uint64_t        dr1;
    uint64_t        dr2;
    uint64_t        dr3;
    uint64_t        dr6;
    uint64_t        dr7;
    /** @} */

    /** Global Descriptor Table register. */
    X86XDTR64       gdtr;
    uint16_t        gdtrPadding;
    /** Interrupt Descriptor Table register. */
    X86XDTR64       idtr;
    uint16_t        idtrPadding;
    /** The task register. */
    RTSEL           ldtr;
    RTSEL           ldtrPadding;
    /** The task register. */
    RTSEL           tr;
    RTSEL           trPadding;

    /** MSRs
     * @{ */
    CPUMSYSENTER    SysEnter;
    uint64_t        FSbase;
    uint64_t        GSbase;
    uint64_t        efer;
    /** @} */

    /** The XCR0 register. */
    uint64_t        xcr0;
    /** The mask to pass to XSAVE/XRSTOR in EDX:EAX.  If zero we use
     *  FXSAVE/FXRSTOR (since bit 0 will always be set, we only need to test it). */
    uint64_t        fXStateMask;

    /* padding to get 64byte aligned size */
    uint8_t         auPadding[24];

} CPUMHOSTCTX;

/** Pointer to the saved host CPU state. */
typedef CPUMHOSTCTX *PCPUMHOSTCTX;


/**
 * The hypervisor context CPU state (just DRx left now).
 */
typedef struct CPUMHYPERCTX
{
    /** Debug registers.
     * @remarks DR4 and DR5 should not be used since they are aliases for
     *          DR6 and DR7 respectively on both AMD and Intel CPUs.
     * @remarks DR8-15 are currently not supported by AMD or Intel, so
     *          neither do we.
     */
    uint64_t        dr[8];
    /** @todo eliminiate the rest.   */
    uint64_t        cr3;
    uint64_t        au64Padding[7];
} CPUMHYPERCTX;

/** Pointer to the hypervisor context CPU state. */
typedef CPUMHYPERCTX *PCPUMHYPERCTX;


/**
 * CPUM Data (part of VM)
 */
typedef struct CPUM
{
    /** Use flags.
     * These flags indicates which CPU features the host uses.
     */
    uint32_t                fHostUseFlags;

    /** CR4 mask
     * @todo obsolete? */
    struct
    {
        uint32_t            AndMask; /**< @todo Move these to the per-CPU structure and fix the switchers. Saves a register! */
        uint32_t            OrMask;
    } CR4;

    /** The (more) portable CPUID level. */
    uint8_t                 u8PortableCpuIdLevel;
    /** Indicates that a state restore is pending.
     * This is used to verify load order dependencies (PGM). */
    uint8_t                    fPendingRestore;
    /** Whether MTRR reads report valid memory types for memory regions. */
    uint8_t                    fMtrrRead;
    /** Whether the guest's writes to MTRRs are implemented. */
    uint8_t                    fMtrrWrite;

    /** XSAVE/XRTOR components we can expose to the guest mask. */
    uint64_t                fXStateGuestMask;
    /** XSAVE/XRSTOR host mask.  Only state components in this mask can be exposed
     * to the guest.  This is 0 if no XSAVE/XRSTOR bits can be exposed. */
    uint64_t                fXStateHostMask;


    /** The host MXCSR mask (determined at init). */
    uint32_t                fHostMxCsrMask;

    uint8_t                 abPadding1[4];

    /** Random value we store in the reserved RFLAGS bits we don't use ourselves so
     *  we can detect corruption. */
    uint64_t                fReservedRFlagsCookie;

    /** Align to 64-byte boundary. */
    uint8_t                 abPadding2[16];

    /** Host CPU feature information.
     * Externaly visible via the VM structure, aligned on 64-byte boundrary. */
    CPUMFEATURES            HostFeatures;
    /** Guest CPU feature information.
     * Externaly visible via that VM structure, aligned with HostFeatures. */
    CPUMFEATURES            GuestFeatures;
    /** Guest CPU info. */
    CPUMINFO                GuestInfo;

    /** The standard set of CpuId leaves. */
    CPUMCPUID               aGuestCpuIdPatmStd[6];
    /** The extended set of CpuId leaves. */
    CPUMCPUID               aGuestCpuIdPatmExt[10];
    /** The centaur set of CpuId leaves. */
    CPUMCPUID               aGuestCpuIdPatmCentaur[4];

    /** @name MSR statistics.
     * @{ */
    STAMCOUNTER             cMsrWrites;
    STAMCOUNTER             cMsrWritesToIgnoredBits;
    STAMCOUNTER             cMsrWritesRaiseGp;
    STAMCOUNTER             cMsrWritesUnknown;
    STAMCOUNTER             cMsrReads;
    STAMCOUNTER             cMsrReadsRaiseGp;
    STAMCOUNTER             cMsrReadsUnknown;
    /** @} */
} CPUM;

/** Pointer to the CPUM instance data residing in the shared VM structure. */
typedef CPUM *PCPUM;

/**
 * CPUM Data (part of VMCPU)
 */
typedef struct CPUMCPU
{
    /** Guest context.
     * Aligned on a 64-byte boundary. */
    CPUMCTX                 Guest;
    /** Guest context - misc MSRs
     * Aligned on a 64-byte boundary. */
    CPUMCTXMSRS             GuestMsrs;

    /** Nested VMX: VMX-preemption timer. */
    TMTIMERHANDLE           hNestedVmxPreemptTimer;

    /** Use flags.
     * These flags indicates both what is to be used and what has been used. */
    uint32_t                fUseFlags;

    /** Changed flags.
     * These flags indicates to REM (and others) which important guest
     * registers which has been changed since last time the flags were cleared.
     * See the CPUM_CHANGED_* defines for what we keep track of.
     *
     * @todo Obsolete, but will probably be refactored so keep it for reference. */
    uint32_t                fChanged;

    /** Temporary storage for the return code of the function called in the
     * 32-64 switcher. */
    uint32_t                u32RetCode;

    /** Whether the X86_CPUID_FEATURE_EDX_APIC and X86_CPUID_AMD_FEATURE_EDX_APIC
     *  (?) bits are visible or not.  (The APIC is responsible for setting this
     *  when loading state, so we won't save it.) */
    uint8_t                    fCpuIdApicFeatureVisible;

    /** Align the next member on a 64-byte boundary. */
    uint8_t                 abPadding2[64 - 8 - 4*3 - 1];

    /** Saved host context.  Only valid while inside RC or HM contexts.
     * Must be aligned on a 64-byte boundary. */
    CPUMHOSTCTX             Host;
    /** Old hypervisor context, only used for combined DRx values now.
     * Must be aligned on a 64-byte boundary. */
    CPUMHYPERCTX            Hyper;


} CPUMCPU;

/** Pointer to the CPUMCPU instance data residing in the shared VMCPU structure. */
typedef CPUMCPU *PCPUMCPU;



/** @} */



