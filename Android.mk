#
# Copyright (C) 2020 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

ifneq ($(filter a02q, $(TARGET_DEVICE)),)
LOCAL_PATH := $(call my-dir)

include $(call all-makefiles-under,$(LOCAL_PATH))

endif
