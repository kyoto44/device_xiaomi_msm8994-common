#!/vendor/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`

case "$target" in "msm8992")
    # Ensure at most two A57 is online when thermal hotplug is disabled
    echo 1 > /sys/devices/system/cpu/cpu4/online
    echo 1 > /sys/devices/system/cpu/cpu5/online

    # Enable LPM sleep
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

    # Disable thermal and bcl hotplug
    echo 0 > /sys/module/msm_thermal/core_control/enabled
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        echo 0 > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        echo 0 > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

    # Disable CPU retention
    echo 0 > /sys/module/lpm_levels/system/a53/cpu0/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu1/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu2/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu3/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/cpu4/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/cpu5/retention/idle_enabled

    # Disable L2 retention
    echo 0 > /sys/module/lpm_levels/system/a53/a53-l2-retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/a57-l2-retention/idle_enabled

    # Configure governor settings for little cluster
    echo 302400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1632000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    echo "sched" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

    # Configure governor settings for big cluster
    echo 302400 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    echo 1824000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
    echo "sched" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

    # Re-enable thermal and bcl hotplug
    echo 1 > /sys/module/msm_thermal/core_control/enabled
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        echo $bcl_hotplug_mask > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

    # Set core_ctl module parameters
    echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
    echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus

    # Enable rps static configuration
    echo 8 >  /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus

    # Set GPU governors
    for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
    do
        echo "bw_hwmon" > $devfreq_gov
    done
    for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
    do
        echo "cpufreq" > $devfreq_gov
    done

    # Some files in /sys/devices/system/cpu are created after the restorecon of
    # /sys/. These files receive the default label "sysfs".
    # Restorecon again to give new files the correct label.
    restorecon -R /sys/devices/system/cpu

    # Relax access permission for display power consumption
    chown -h system /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    chown -h system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    chown -h system /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    chown -h system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

    # Set GPU default power level to 7 (64MHz)
    echo 7 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel
    ;;
esac

case "$target" in "msm8994")
    # Ensure at most four A57 is online when thermal hotplug is disabled
    echo 1 > /sys/devices/system/cpu/cpu5/online
    echo 1 > /sys/devices/system/cpu/cpu6/online
    echo 1 > /sys/devices/system/cpu/cpu7/online

    # Enable LPM sleep
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

    # Disable thermal and bcl hotplug
    echo 0 > /sys/module/msm_thermal/core_control/enabled
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        echo 0 > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        echo 0 > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

    # Disable CPU retention
    echo 0 > /sys/module/lpm_levels/system/a53/cpu0/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu1/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu2/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a53/cpu3/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/cpu4/retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/cpu5/retention/idle_enabled

    # Disable L2 retention
    echo 0 > /sys/module/lpm_levels/system/a53/a53-l2-retention/idle_enabled
    echo 0 > /sys/module/lpm_levels/system/a57/a57-l2-retention/idle_enabled

    # Configure governor settings for little cluster
    echo 302400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1440000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "80 580000:63 680000:54 780000:60 880000:32 1180000:98 1280000:93" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
    echo "38000 1280000:58000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
    echo 98 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
    echo 1180000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
    echo 38000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
    echo 180000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows
    echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
    echo 250000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

    # Configure governor settings for big cluster
    echo 384000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    echo 1824000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
    echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo "80 480000:44 580000:65 680000:61 780000:20 880000:90 1180000:74 1280000:98" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
    echo "78000 1280000:38000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
    echo 98 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
    echo 1180000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
    echo 78000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
    echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
    echo 180000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows
    echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
    echo 125000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration

    # Re-enable thermal and bcl hotplug
    echo 1 > /sys/module/msm_thermal/core_control/enabled
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        echo $bcl_hotplug_mask > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

    # Set core_ctl module parameters
    echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    echo 30 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
    echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
    echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres
    echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus

    # Set b.L scheduler parameters
    echo 1 > /proc/sys/kernel/power_aware_timer_migration
    echo 1 > /proc/sys/kernel/sched_migration_fixup
    echo 30 > /proc/sys/kernel/sched_small_task
    echo 95 > /proc/sys/kernel/sched_upmigrate
    echo 85 > /proc/sys/kernel/sched_downmigrate
    echo 2 > /proc/sys/kernel/sched_window_stats_policy
    echo 5 > /proc/sys/kernel/sched_ravg_hist_size
    echo 90 > /proc/sys/kernel/sched_spill_load
    echo 0 > /proc/sys/kernel/sched_boost

    # Enable rps static configuration
    echo 8 >  /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus

    # Set GPU governors
    for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
    do
        echo "bw_hwmon" > $devfreq_gov
    done
    for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
    do
        echo "cpufreq" > $devfreq_gov
    done

    # Some files in /sys/devices/system/cpu are created after the restorecon of
    # /sys/. These files receive the default label "sysfs".
    # Restorecon again to give new files the correct label.
    restorecon -R /sys/devices/system/cpu

    # Relax access permission for display power consumption
    chown -h system /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    chown -h system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    chown -h system /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    chown -h system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

    # Disable sched_boost
    echo 0 > /proc/sys/kernel/sched_boost

    # Input boost configuration
    echo 0:580000 4:480000 > /sys/module/cpu_boost/parameters/input_boost_freq
    echo 100 > /sys/module/cpu_boost/parameters/input_boost_ms
esac

rm /data/system/perfd/default_values
start perfd

# Let kernel know our image version/variant/crm_version
image_version="10:"
image_version+=`getprop ro.build.id`
image_version+=":"
image_version+=`getprop ro.build.version.incremental`
image_variant=`getprop ro.product.name`
image_variant+="-"
image_variant+=`getprop ro.build.type`
oem_version=`getprop ro.build.version.codename`
echo 10 > /sys/devices/soc0/select_image
echo $image_version > /sys/devices/soc0/image_version
echo $image_variant > /sys/devices/soc0/image_variant
echo $oem_version > /sys/devices/soc0/image_crm_version