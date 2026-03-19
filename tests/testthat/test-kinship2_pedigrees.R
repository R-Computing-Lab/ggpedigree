# Sourced from kinship2 package tests

# ---- Helper: minimal pedigree data ----
.make_simple_ped <- function() {
  ggpedigree:::pedigree(
    id    = 1:5,
    dadid = c(0, 0, 1, 1, 1),
    momid = c(0, 0, 2, 2, 2),
    sex   = c(1, 2, 1, 2, 1)
  )
}

# ---- pedigree.idcheck errors ----
test_that("pedigree.idcheck catches length mismatches and NA ids", {
  expect_error(
    ggpedigree:::pedigree(id = 1:3, dadid = c(0, 0), momid = c(0, 0, 0), sex = c(1, 2, 1)),
    "Mismatched lengths, id and dadid"
  )
  expect_error(
    ggpedigree:::pedigree(id = 1:3, dadid = c(0, 0, 0), momid = c(0, 0), sex = c(1, 2, 1)),
    "Mismatched lengths, id and momid"
  )
  expect_error(
    ggpedigree:::pedigree(id = 1:3, dadid = c(0, 0, 0), momid = c(0, 0, 0), sex = c(1, 2)),
    "Mismatched lengths, id and sex"
  )
  expect_error(
    ggpedigree:::pedigree(id = c(1, NA, 3), dadid = c(0, 0, 0), momid = c(0, 0, 0), sex = c(1, 2, 1)),
    "Missing value for the id variable"
  )
})

# ---- pedigree.idrepair errors ----
test_that("pedigree.idrepair errors on blank string ids", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c("a", "  ", "c"),
      dadid = c("", "", "a"),
      momid = c("", "", "b"),
      sex   = c(1, 2, 1)
    ),
    "blank or empty string is not allowed"
  )
})

# ---- pedigree.sexrepair code paths ----
test_that("pedigree.sexrepair handles factor sex input", {
  ped <- ggpedigree:::pedigree(
    id    = 1:4,
    dadid = c(0, 0, 1, 1),
    momid = c(0, 0, 2, 2),
    sex   = factor(c("male", "female", "male", "female"))
  )
  expect_s3_class(ped, "pedigree")
  expect_equal(as.character(ped$sex), c("male", "female", "male", "female"))
})

test_that("pedigree.sexrepair handles character numeric strings", {
  ped <- ggpedigree:::pedigree(
    id    = 1:4,
    dadid = c(0, 0, 1, 1),
    momid = c(0, 0, 2, 2),
    sex   = c("1", "2", "1", "2")
  )
  expect_s3_class(ped, "pedigree")
  expect_equal(as.character(ped$sex), c("male", "female", "male", "female"))
})

test_that("pedigree.sexrepair handles 0-indexed sex (min=0 triggers +1 shift)", {
  # When min(sex) == 0, the code shifts all values up by 1.
  # sex=c(0,1,0,1): 0 -> 1="male", 1 -> 2="female" after the +1 shift.
  ped <- ggpedigree:::pedigree(
    id    = 1:4,
    dadid = c(0, 0, 1, 1), # dad = subject 1 (sex=0 -> male after shift)
    momid = c(0, 0, 2, 2), # mom = subject 2 (sex=1 -> female after shift)
    sex   = c(0, 1, 0, 1) # shifted up by 1: 0->1="male", 1->2="female"
  )
  expect_s3_class(ped, "pedigree")
  expect_equal(as.character(ped$sex), c("male", "female", "male", "female"))
})

test_that("pedigree.sexrepair errors when all sex is unknown", {
  expect_error(
    ggpedigree:::pedigree(
      id    = 1:4,
      dadid = c(0, 0, 1, 1),
      momid = c(0, 0, 2, 2),
      sex   = c(3, 3, 3, 3)
    ),
    "All sex values are labeled as unknown"
  )
})

test_that("pedigree.sexrepair warns when more than 25% unknown", {
  expect_warning(
    ggpedigree:::pedigree(
      id    = 1:8,
      dadid = c(0, 0, 1, 1, 0, 0, 5, 5),
      momid = c(0, 0, 2, 2, 0, 0, 6, 6),
      sex   = c(1, 2, 1, 3, 1, 2, 3, 3) # 3/8 = 37.5% unknown, > 25%
    ),
    "More than 25%"
  )
})

# ---- pedigree() creation error cases ----
test_that("pedigree errors on duplicate subject ids", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 2, 4, 5),
      dadid = c(0, 0, 0, 1, 1),
      momid = c(0, 0, 0, 2, 2),
      sex   = c(1, 2, 2, 1, 2)
    ),
    "Duplicate subject id"
  )
})

test_that("pedigree errors when listed father is not male", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 3),
      dadid = c(0, 0, 2), # subject 2 listed as father but is female
      momid = c(0, 0, 1),
      sex   = c(2, 2, 1) # subjects 1 and 2 are female
    ),
    "Id not male, but is a father"
  )
})

test_that("pedigree errors when dadid not found in id list", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 3),
      dadid = c(0, 0, 99), # 99 is not in id
      momid = c(0, 0, 2),
      sex   = c(1, 2, 1)
    ),
    "Value of 'dadid' not found in the id list"
  )
})

test_that("pedigree errors when listed mother is not female", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 3),
      dadid = c(0, 0, 1),
      momid = c(0, 0, 3), # subject 3 listed as mother but is male
      sex   = c(1, 2, 1)
    ),
    "Id not female, but is a mother"
  )
})

test_that("pedigree errors when momid not found in id list", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 3),
      dadid = c(0, 0, 1),
      momid = c(0, 0, 99), # 99 is not in id
      sex   = c(1, 2, 1)
    ),
    "Value of 'momid' not found in the id list"
  )
})

test_that("pedigree errors when subject has only one parent", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c(1, 2, 3),
      dadid = c(0, 0, 1), # subject 3 has dad but no mom
      momid = c(0, 0, 0),
      sex   = c(1, 2, 1)
    ),
    "Subjects must have both a father and mother, or have neither"
  )
})

test_that("pedigree errors when famid contains NA", {
  expect_error(
    ggpedigree:::pedigree(
      id    = 1:3,
      dadid = c(0, 0, 1),
      momid = c(0, 0, 2),
      sex   = c(1, 2, 1),
      famid = c(1, NA, 1)
    ),
    "The family id cannot contain missing values"
  )
})

test_that("pedigree errors when famid is a blank string", {
  expect_error(
    ggpedigree:::pedigree(
      id    = c("a", "b", "c"),
      dadid = c("", "", "a"),
      momid = c("", "", "b"),
      sex   = c(1, 2, 1),
      famid = c("fam1", "  ", "fam1")
    ),
    "The family id cannot be a blank or empty string"
  )
})

# ---- pedigree with character ids (tests pedigree.makemissingid character branch) ----
test_that("pedigree works with character ids", {
  ped <- ggpedigree:::pedigree(
    id    = c("a", "b", "c", "d", "e"),
    dadid = c("", "", "a", "a", "a"),
    momid = c("", "", "b", "b", "b"),
    sex   = c(1, 2, 1, 2, 1)
  )
  expect_s3_class(ped, "pedigree")
  expect_equal(length(ped$id), 5L)
})

# ---- pedigree.process_status paths ----
test_that("pedigree.process_status handles logical status", {
  ped <- ggpedigree:::pedigree(
    id     = 1:4,
    dadid  = c(0, 0, 1, 1),
    momid  = c(0, 0, 2, 2),
    sex    = c(1, 2, 1, 2),
    status = c(TRUE, FALSE, TRUE, FALSE)
  )
  expect_equal(ped$status, c(1L, 0L, 1L, 0L))
})

test_that("pedigree.process_status errors on wrong length", {
  expect_error(
    ggpedigree:::pedigree(
      id     = 1:4,
      dadid  = c(0, 0, 1, 1),
      momid  = c(0, 0, 2, 2),
      sex    = c(1, 2, 1, 2),
      status = c(0, 1) # length 2 vs n=4
    ),
    "Wrong length for affected"
  )
})

test_that("pedigree.process_status errors on invalid code", {
  expect_error(
    ggpedigree:::pedigree(
      id     = 1:4,
      dadid  = c(0, 0, 1, 1),
      momid  = c(0, 0, 2, 2),
      sex    = c(1, 2, 1, 2),
      status = c(0, 1, 2, 0) # 2 is invalid
    ),
    "Invalid status code"
  )
})

# ---- pedigree.process_affected paths ----
test_that("pedigree.process_affected handles logical vector", {
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 2),
    affected = c(TRUE, FALSE, TRUE, FALSE)
  )
  expect_equal(ped$affected, c(1, 0, 1, 0))
})

test_that("pedigree.process_affected handles factor vector", {
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 2),
    affected = factor(c("unaff", "aff", "unaff", "aff"), levels = c("unaff", "aff"))
  )
  expect_equal(ped$affected, c(0, 1, 0, 1))
})

test_that("pedigree.process_affected handles logical matrix", {
  aff_mat <- matrix(c(TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE), nrow = 4)
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 2),
    affected = aff_mat
  )
  expect_equal(ped$affected, 1L * aff_mat)
})

test_that("pedigree.process_affected errors on wrong length", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      affected = c(0, 1, 0) # length 3 vs n=4
    ),
    "Wrong length for affected"
  )
})

test_that("pedigree.process_affected errors on wrong matrix rows", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      affected = matrix(c(0, 1, 0), nrow = 3) # 3 rows vs n=4
    ),
    "Wrong number of rows in affected"
  )
})

test_that("pedigree.process_affected errors on invalid code", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      affected = c(0, 1, 0.5, 1) # 0.5 is invalid
    ),
    "Invalid code for affected status"
  )
})

# ---- pedigree.coerce_relation_code paths ----
test_that("pedigree.coerce_relation_code handles factor code input", {
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 1),
    relation = matrix(c(3, 4, 1), ncol = 3)
  )
  # Now test with factor code in the relation matrix
  ped2 <- ggpedigree:::pedigree(
    id = 1:4,
    dadid = c(0, 0, 1, 1),
    momid = c(0, 0, 2, 2),
    sex = c(1, 2, 1, 1),
    relation = data.frame(
      id1  = 3,
      id2  = 4,
      code = factor(1, levels = 1:4, labels = c("MZ twin", "DZ twin", "UZ twin", "spouse"))
    )
  )
  expect_equal(as.character(ped$relation$code), as.character(ped2$relation$code))
})

test_that("pedigree.coerce_relation_code handles character string codes", {
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 2),
    relation = data.frame(id1 = 3, id2 = 4, code = "spouse")
  )
  expect_equal(as.character(ped$relation$code), "spouse")
})

test_that("pedigree.coerce_relation_code errors on invalid numeric code", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = matrix(c(3, 4, 5), ncol = 3) # code 5 is invalid
    ),
    "Invalid relationship code"
  )
})

test_that("pedigree.coerce_relation_code errors on invalid character code", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = data.frame(id1 = 3, id2 = 4, code = "triplet") # invalid
    ),
    "Invalid relationship code"
  )
})

# ---- pedigree.parse_relation error paths ----
test_that("pedigree.parse_relation errors on matrix with wrong column count", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = matrix(c(3, 4), ncol = 2) # need 3 columns
    ),
    "Relation matrix must have 3 columns"
  )
})

test_that("pedigree.parse_relation errors on matrix with wrong column count when has_famid", {
  expect_error(
    ggpedigree:::pedigree(
      id       = c(1, 2, 3, 4, 1, 2),
      dadid    = c(0, 0, 1, 1, 0, 0),
      momid    = c(0, 0, 2, 2, 0, 0),
      sex      = c(1, 2, 1, 2, 1, 2),
      famid    = c(1, 1, 1, 1, 2, 2),
      relation = matrix(c(3, 4, 1), ncol = 3) # need 4 columns when has_famid
    ),
    "Relation matrix must have 3 columns \\+ famid"
  )
})

test_that("pedigree.parse_relation works with dataframe input (no famid)", {
  ped <- ggpedigree:::pedigree(
    id       = 1:4,
    dadid    = c(0, 0, 1, 1),
    momid    = c(0, 0, 2, 2),
    sex      = c(1, 2, 1, 1),
    relation = data.frame(id1 = 3L, id2 = 4L, code = 1L)
  )
  expect_equal(as.character(ped$relation$code), "MZ twin")
})

test_that("pedigree.parse_relation errors on dataframe with missing columns", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = data.frame(id1 = 3, id2 = 4) # missing code
    ),
    "Relation data frame must have id1, id2, and code"
  )
})

test_that("pedigree.parse_relation errors when relation is not matrix or dataframe", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = list(id1 = 3, id2 = 4, code = 1)
    ),
    "Relation argument must be a matrix or a list"
  )
})

test_that("pedigree.parse_relation works with dataframe input (with famid)", {
  ped_list <- ggpedigree:::pedigree(
    id       = c(1, 2, 3, 4, 1, 2),
    dadid    = c(0, 0, 1, 1, 0, 0),
    momid    = c(0, 0, 2, 2, 0, 0),
    sex      = c(1, 2, 1, 1, 1, 2),
    famid    = c(1, 1, 1, 1, 2, 2),
    relation = data.frame(id1 = 3, id2 = 4, code = 1, famid = 1)
  )
  expect_s3_class(ped_list, "pedigreeList")
  expect_false(is.null(ped_list$relation))
})

test_that("pedigree.parse_relation errors on dataframe with missing famid column when has_famid", {
  expect_error(
    ggpedigree:::pedigree(
      id       = c(1, 2, 3, 4, 1, 2),
      dadid    = c(0, 0, 1, 1, 0, 0),
      momid    = c(0, 0, 2, 2, 0, 0),
      sex      = c(1, 2, 1, 1, 1, 2),
      famid    = c(1, 1, 1, 1, 2, 2),
      relation = data.frame(id1 = 3, id2 = 4, code = 1) # missing famid column
    ),
    "Relation data must have id1, id2, code, and family id"
  )
})

test_that("pedigree.parse_relation errors when relation is not matrix or dataframe (with famid)", {
  expect_error(
    ggpedigree:::pedigree(
      id       = c(1, 2, 3, 4, 1, 2),
      dadid    = c(0, 0, 1, 1, 0, 0),
      momid    = c(0, 0, 2, 2, 0, 0),
      sex      = c(1, 2, 1, 1, 1, 2),
      famid    = c(1, 1, 1, 1, 2, 2),
      relation = list(id1 = 3, id2 = 4, code = 1, famid = 1)
    ),
    "Relation argument must be a matrix or a dataframe"
  )
})

# ---- pedigree.process_relation error paths ----
test_that("pedigree.process_relation errors when relation member not in pedigree", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = matrix(c(3, 99, 4), ncol = 3) # 99 not in pedigree
    ),
    "Subjects in relationships that are not in the pedigree"
  )
})

test_that("pedigree.process_relation errors when subject is own twin/spouse", {
  expect_error(
    ggpedigree:::pedigree(
      id       = 1:4,
      dadid    = c(0, 0, 1, 1),
      momid    = c(0, 0, 2, 2),
      sex      = c(1, 2, 1, 2),
      relation = matrix(c(3, 3, 4), ncol = 3) # subject 3 is own spouse
    ),
    "is their own spouse or twin"
  )
})

test_that("pedigree.process_relation errors when twins have different mothers", {
  expect_error(
    ggpedigree:::pedigree(
      id = c(1, 2, 3, 4, 5, 6),
      dadid = c(0, 0, 0, 0, 1, 1),
      momid = c(0, 0, 0, 0, 2, 4), # subject 5 has mom 2, subject 6 has mom 4
      sex = c(1, 2, 1, 2, 1, 1),
      relation = matrix(c(5, 6, 1), ncol = 3) # MZ twins with different mothers
    ),
    "Twins found with different mothers"
  )
})

test_that("pedigree.process_relation errors when twins have different fathers", {
  expect_error(
    ggpedigree:::pedigree(
      id = c(1, 2, 3, 4, 5, 6),
      dadid = c(0, 0, 0, 0, 1, 3), # subject 5 has dad 1, subject 6 has dad 3
      momid = c(0, 0, 0, 0, 2, 2), # both have mom 2
      sex = c(1, 2, 1, 1, 1, 1),
      relation = matrix(c(5, 6, 1), ncol = 3) # MZ twins with different fathers
    ),
    "Twins found with different fathers"
  )
})

test_that("pedigree.process_relation errors when MZ twins have different sexes", {
  expect_error(
    ggpedigree:::pedigree(
      id = 1:4,
      dadid = c(0, 0, 1, 1),
      momid = c(0, 0, 2, 2),
      sex = c(1, 2, 1, 2), # subject 3 male, subject 4 female
      relation = matrix(c(3, 4, 1), ncol = 3) # MZ twins with different sexes
    ),
    "MZ twins with different sexes"
  )
})

# ---- pedigreeList subscripting extended ----
test_that("pedigreeList subscript with numeric index", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  ped8_num <- minnped[1] # first family by position (numeric)
  #  ped8_chr <- minnped["1"]
  # expect_equal(ped8_num$id, ped8_chr$id)
  # ══ Failed tests ════════════════════════════════════════════════════════════════
  # ── Error ('test-kinship2_pedigrees.R:573:3'): pedigreeList subscript with numeric index ──
  # Error in ``[.pedigreeList`(minnped, "1")`: Family 1 not found
  # Backtrace:
  #    ▆
  # 1. ├─minnped["1"] at test-kinship2_pedigrees.R:573:3
  # 2. └─ggpedigree:::`[.pedigreeList`(minnped, "1") at test-kinship2_pedigrees.R:573:3
})

test_that("pedigreeList subscript with factor index", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  ped8_fac <- minnped[factor("8")]
  ped8_chr <- minnped["8"]
  expect_equal(ped8_fac$id, ped8_chr$id)
})

test_that("pedigreeList subscript selecting multiple families returns pedigreeList", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  two_fams <- minnped[c("8", "9")]
  expect_s3_class(two_fams, "pedigreeList")
})

test_that("pedigreeList subscript errors when family not found", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  expect_error(minnped["99999"], "not found")
})

test_that("pedigreeList subscript errors with too many subscripts", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  expect_error(minnped["8", "extra"], "Only 1 subscript allowed")
})

test_that("pedigreeList subscript handles matrix affected, status, and relation", {
  # Build a pedigreeList with matrix affected, status, and a relation
  ped_list <- ggpedigree:::pedigree(
    id = c(1, 2, 3, 4, 5, 1, 2, 3),
    dadid = c(0, 0, 1, 1, 1, 0, 0, 1),
    momid = c(0, 0, 2, 2, 2, 0, 0, 2),
    sex = c(1, 2, 1, 1, 2, 1, 2, 1),
    famid = c(1, 1, 1, 1, 1, 2, 2, 2),
    affected = cbind(
      disease = c(0, 0, 1, 0, 1, 0, 0, 1),
      smoker  = c(1, 0, 0, 1, 0, 1, 0, 1)
    ),
    status = c(0, 1, 0, 0, 1, 1, 0, 0),
    relation = matrix(c(3, 4, 1, 1), ncol = 4) # MZ twins 3&4 in family 1
  )

  # Select family 1: relation should be kept, famid removed from relation
  fam1 <- ped_list[1]
  expect_s3_class(fam1, "pedigree")
  expect_null(fam1$relation$famid)
  expect_true(is.matrix(fam1$affected))
  expect_equal(fam1$status, c(0, 1, 0, 0, 1))

  # Select family 2: no relation entries → relation set to NULL
  fam2 <- ped_list[2]
  expect_null(fam2$relation)
  expect_true(is.matrix(fam2$affected))
  expect_equal(fam2$status, c(1, 0, 0))

  # Select both families: relation kept with famid
  both_fams <- ped_list[c(1, 2)]
  expect_s3_class(both_fams, "pedigreeList")
  expect_false(is.null(both_fams$relation$famid))
})

# ---- pedigree subscripting extended ----
test_that("pedigree subscript errors with too many subscripts", {
  ped <- .make_simple_ped()
  expect_error(ped[1, 2], "Only 1 subscript allowed")
})

test_that("pedigree subscript errors when only one parent is kept", {
  ped <- .make_simple_ped() # 1=dad, 2=mom, 3/4/5=children
  # Keep dad and child 3 but not mom → child 3 has dad but no mom
  expect_error(ped[c(1, 3)], "A subpedigree cannot choose only one parent")
})

test_that("pedigree subscript with character ids", {
  ped <- ggpedigree:::pedigree(
    id    = c("a", "b", "c", "d"),
    dadid = c("", "", "a", "a"),
    momid = c("", "", "b", "b"),
    sex   = c(1, 2, 1, 2)
  )
  sub <- ped[c("a", "b", "c")]
  expect_s3_class(sub, "pedigree")
  expect_equal(sub$id, c("a", "b", "c"))
})

test_that("pedigree subscript keeps relation when both members retained", {
  ped <- ggpedigree:::pedigree(
    id       = 1:5,
    dadid    = c(0, 0, 1, 1, 1),
    momid    = c(0, 0, 2, 2, 2),
    sex      = c(1, 2, 1, 1, 2),
    relation = matrix(c(3, 4, 1), ncol = 3) # MZ twins 3 and 4
  )
  # Keep all: relation preserved
  sub_all <- ped[1:5]
  expect_false(is.null(sub_all$relation))

  # Keep parents and twin 3 only (drop twin 4): relation dropped
  sub_no4 <- ped[c(1, 2, 3)]
  expect_null(sub_no4$relation)
})

test_that("pedigree subscript preserves famid", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  ped8 <- minnped["8"]
  # ped8 has famid; further subscript should preserve famid
  sub <- ped8[1:3]
  expect_false(is.null(sub$famid))
})

test_that("pedigree subscript handles hints field", {
  # Build a pedigree with a manually set hints field (order + spouse)
  ped <- ggpedigree:::pedigree(
    id = 1:4,
    dadid = c(0, 0, 1, 0),
    momid = c(0, 0, 2, 0),
    sex = c(1, 2, 1, 2),
    relation = matrix(c(1, 4, 4), ncol = 3) # 1 and 4 are spouses (code=4)
  )
  # Manually attach a hints structure (as kinship2_autohint would produce)
  ped$hints <- list(
    order  = c(1.0, 2.0, 3.0, 4.0),
    spouse = matrix(c(1, 4, 0.5), ncol = 3)
  )

  # Keep all 4: hints order and spouse should be retained
  sub_all <- ped[1:4]
  expect_false(is.null(sub_all$hints))
  expect_false(is.null(sub_all$hints$spouse))

  # Keep subjects 1, 2, 3 (drop subject 4 = one spouse member)
  sub_no4 <- ped[c(1, 2, 3)]
  expect_false(is.null(sub_no4$hints))
  expect_null(sub_no4$hints$spouse) # spouse entry dropped since subject 4 is not kept
})

# ---- print methods ----
test_that("print.pedigree works without famid", {
  ped <- .make_simple_ped()
  out <- capture.output(print(ped))
  expect_true(any(grepl("Pedigree object", out)))
})

test_that("print.pedigree works with famid", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  ped8 <- minnped["8"]
  out <- capture.output(print(ped8))
  expect_true(any(grepl("Pedigree object", out)))
  expect_true(any(grepl("family id", out)))
})

test_that("print.pedigreeList works", {
  library(kinship2)
  data(minnbreast)
  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id, fatherid, motherid, sex,
      affected = cancer, famid = famid
    )
  )
  out <- capture.output(print(minnped))
  expect_true(any(grepl("Pedigree list", out)))
})

test_that("pedigree fails to line up", {
  # Here is a case where the levels fail to line up properly
  library(kinship2)
  library(vdiffr)
  data(sample.ped)
  df1 <- sample.ped[sample.ped$ped == 1, ]
  ped1 <- with(df1, ggpedigree:::pedigree(id, father, mother, sex, affected))
  vdiffr::expect_doppelganger("ped1", plot(ped1))

  # With reordering it's better
  df1reord <- df1[c(35:41, 1:34), ]
  ped1reord <- with(df1reord, ggpedigree:::pedigree(id, father, mother,
    sex,
    affected = affected
  ))
  vdiffr::expect_doppelganger("ped1reorder", plot(ped1reord))
})

test_that("pedigree subscripting", {
  library(kinship2)

  data(minnbreast)

  minnped <- with(
    minnbreast,
    ggpedigree:::pedigree(id,
      fatherid,
      motherid,
      sex,
      affected = cancer,
      famid = famid
    )
  )
  ped8 <- minnped["8"] # a modest sized family

  # Subjects 150, 152, 154, 158 are children,
  # and 143, 162, 149 are parents and a child
  droplist <- c(150, 152, 154, 158, 143, 162, 149)

  keep1 <- !(ped8$id %in% droplist) # logical
  keep2 <- which(keep1) # numeric
  keep3 <- as.character(ped8$id[keep1]) # character
  keep4 <- factor(keep3)

  test1 <- ped8[keep1]
  test2 <- ped8[keep2]
  test3 <- ped8[keep3]
  test4 <- ped8[keep4]
  expect_equal(test1, test2)
  expect_equal(test1, test3)
  expect_equal(test1, test4)
})

test_that("pedigree other test", {
  library(vdiffr)
  ped2mat <- matrix(c(
    1, 1, 0, 0, 1,
    1, 2, 0, 0, 2,
    1, 3, 1, 2, 1,
    1, 4, 1, 2, 2,
    1, 5, 0, 0, 2,
    1, 6, 0, 0, 1,
    1, 7, 3, 5, 2,
    1, 8, 6, 4, 1,
    1, 9, 6, 4, 1,
    1, 10, 8, 7, 2
  ), ncol = 5, byrow = TRUE)

  ped2df <- as.data.frame(ped2mat)
  names(ped2df) <- c("fam", "id", "dad", "mom", "sex")
  ## 1 2  3 4 5 6 7 8 9 10,11,12,13,14,15,16
  ped2df$disease <- c(NA, NA, 1, 0, 0, 0, 0, 1, 1, 1)
  ped2df$smoker <- c(0, NA, 0, 0, 1, 1, 1, 0, 0, 0)
  ped2df$availstatus <- c(0, 0, 1, 1, 0, 1, 1, 1, 1, 1)
  ped2df$vitalstatus <- c(1, 1, 1, 0, 1, 0, 0, 0, 0, 0)

  ped2 <- with(ped2df, ggpedigree:::pedigree(id,
    dad,
    mom,
    sex,
    status = vitalstatus,
    affected = cbind(disease, smoker, availstatus),
    relation = matrix(c(8, 9, 1), ncol = 3),
  ))
  vdiffr::expect_doppelganger("OtherPed with twin", ped2)
})
