# Code Cleanup Session - January 9, 2026

## Overview
This document captures the code cleanup and refactoring performed on `app.py` for the Net Rates Calculator V2 application. The cleanup was done in 4 staged commits to minimize risk and allow testing between changes.

---

## Commits Made

| Commit | Hash | Description |
|--------|------|-------------|
| Stage 1 | `927136e` | Remove duplicate functions, imports, and clean up |
| Stage 2 | `d072744` | Extract transport types/charges to constants |
| Stage 3 | `8c5676a` | Extract custom price loading to single function |
| Stage 4 | `4c0c6a5` | Move helper functions to module level |

---

## Detailed Changes

### Stage 1: Remove Duplicates & Clean Up

**Commit:** `927136e`

**Changes:**
1. **Removed duplicate `get_available_pdf_files()` function**
   - Was defined twice: ~line 467 and ~line 627
   - Kept the first definition

2. **Removed duplicate `load_excel_with_timestamp()` function**
   - Was defined twice: ~line 476 and ~line 636
   - Kept the first definition

3. **Removed duplicate `import os`**
   - Was imported at line 17 and again at line 624
   - Kept only the top-level import

4. **Moved `SCRIPT_DIR` and `DEFAULT_EXCEL_PATH` to config section**
   - Previously defined mid-file (~line 625)
   - Now defined at top with other configuration constants

5. **Cleaned up ~50 empty lines at end of file**

---

### Stage 2: Extract Transport Constants

**Commit:** `d072744`

**Changes:**
1. **Added new constants at top of file:**
   ```python
   TRANSPORT_TYPES = [
       "Standard - small tools", "Towables", "Non-mechanical", "Fencing",
       "Tower", "Powered Access", "Low-level Access", "Long Distance"
   ]
   DEFAULT_TRANSPORT_CHARGES = ["5", "7.5", "10", "15", "5", "Negotiable", "5", "15"]
   ```

2. **Replaced 5 duplicate array definitions with constants:**
   - `process_excel_to_json()` function (~line 360)
   - `generate_customer_pdf()` function (~line 936)
   - Transport Charges section (~line 2110)
   - Sidebar Export Options (~line 2480)
   - Sidebar Email section (~line 2710)

**Lines reduced:** ~35 lines

---

### Stage 3: Extract Custom Price Loading

**Commit:** `8c5676a`

**Changes:**
1. **Created new `apply_pending_custom_prices(df)` function**
   - Location: After `handle_file_loading()` function
   - Purpose: Apply pending custom prices from loaded progress files to session state
   - Handles O(1) lookup via dictionary for performance with large datasets
   - Shows progress indicator for 20+ items

2. **Replaced two ~45-line duplicate blocks with function calls:**
   - Uploaded Excel file path
   - Default Excel file path

3. **Removed redundant `import os` inside elif block**

4. **Fixed minor bug:** Progress indicator success message was inside wrong indentation block

**Lines reduced:** ~33 lines

---

### Stage 4: Move Helper Functions

**Commit:** `4c0c6a5`

**Changes:**
1. **Moved 7 pure utility functions to module level** (after imports, before Syrinx functions):
   - `is_poa_value(value)` - Check if value is POA
   - `get_numeric_price(value)` - Convert to numeric, None if POA
   - `format_price_display(value)` - Format with £ symbol
   - `format_price_for_export(value)` - Format for export (no £)
   - `format_custom_price_for_export(value)` - Format custom price
   - `format_discount_for_export(value)` - Format discount %
   - `format_custom_price_for_display(value)` - Format with £ symbol

2. **Kept 2 session-dependent functions inside conditional block:**
   - `get_discounted_price(row)` - Requires `global_discount` variable
   - `calculate_discount_percent(original, custom)` - Uses `is_poa_value` and `get_numeric_price`

3. **Renamed section header** from "Helper Functions" to "Session-Dependent Helper Functions"

**Benefit:** Functions are now defined before they're called (proper code organization)

---

## File Structure After Cleanup

```
app.py (~2827 lines)
├── Imports (lines 1-30)
├── Configuration Management (lines 42-60)
│   ├── CONFIG_FILE
│   ├── SCRIPT_DIR
│   ├── DEFAULT_EXCEL_PATH
│   ├── TRANSPORT_TYPES (NEW)
│   └── DEFAULT_TRANSPORT_CHARGES (NEW)
├── Email Configuration (lines 60-110)
├── Session State Functions (lines 110-210)
├── File Loading Functions (lines 210-270)
│   ├── handle_file_loading()
│   └── apply_pending_custom_prices() (NEW)
├── Price/POA Helper Functions (NEW location, lines 275-340)
│   ├── is_poa_value()
│   ├── get_numeric_price()
│   ├── format_price_display()
│   ├── format_price_for_export()
│   ├── format_custom_price_for_export()
│   ├── format_discount_for_export()
│   └── format_custom_price_for_display()
├── Syrinx Import Functions (lines 345-430)
├── Excel to JSON Functions (lines 430-500)
├── PDF/File Utility Functions (lines 500-700)
├── generate_customer_pdf() (lines 713-1000)
├── Email Functions (lines 1000-1300)
├── Main UI Flow (lines 1300-2100)
│   └── Session-Dependent Helper Functions (inside conditional)
│       ├── get_discounted_price()
│       └── calculate_discount_percent()
├── Admin Dashboard (lines 2100-2280)
└── Sidebar (lines 2280-2827)
```

---

## Testing Notes

After each stage, the following should be tested:

### Stage 1
- [ ] App loads without errors
- [ ] PDF header dropdown populates correctly
- [ ] Can load/upload Excel file

### Stage 2
- [ ] Transport Charges section displays correctly
- [ ] PDF generation includes correct transport table (page 3)
- [ ] Excel export includes transport sheet
- [ ] Email includes transport data

### Stage 3 (⚠️ Important)
- [ ] **Load Progress from JSON file** - custom prices load correctly
- [ ] Upload Excel file works
- [ ] Default Excel loads on startup

### Stage 4
- [ ] PDF generation works (uses `is_poa_value`)
- [ ] Excel export formats prices correctly
- [ ] POA values display properly throughout

---

## Rollback Instructions

If issues are found, you can rollback to any previous commit:

```bash
# View commit history
git log --oneline -10

# Rollback to before all changes (before Stage 1)
git checkout e417cd3 -- app.py

# Rollback to after Stage 1
git checkout 927136e -- app.py

# Rollback to after Stage 2
git checkout d072744 -- app.py

# Rollback to after Stage 3
git checkout 8c5676a -- app.py
```

---

## Summary Statistics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total Lines | ~2908 | ~2827 | -81 |
| Duplicate Functions | 2 | 0 | -2 |
| Duplicate Imports | 2 | 0 | -2 |
| Duplicated Code Blocks | 7 | 0 | -7 |
| Constants Defined | 2 | 4 | +2 |

---

*Document created: January 9, 2026*
*Repository: HMPorl/net-rates-v2*
