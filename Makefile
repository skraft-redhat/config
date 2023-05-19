
_default: all

# Define descriptions and the include/exclude lists for each policy
minimal_description=Include a minimal set of basic checks.
minimal_include=["@minimal"]
minimal_exclude=[]

slsa1_description=The minimal rules plus the rules for level 1 of SLSA v0.1.
slsa1_include=["@minimal", "@slsa1"]
slsa1_exclude=[]

slsa2_description=The minimal rules plus the rules for levels 1 & 2 of SLSA v0.1.
slsa2_include=["@minimal", "@slsa1", "@slsa2"]
slsa2_exclude=[]

slsa3_description=The minimal rules plus the rules for levels 1, 2 & 3 of SLSA v0.1.
slsa3_include=["@minimal", "@slsa1", "@slsa2", "@slsa3"]
slsa3_exclude=[]

everything_description=Include every rule in the default policy source.
everything_include=["*"]
everything_exclude=[]

# Currently the default policy is the same as the minimal policy
default_description=$(minimal_description) (Currently identical to 'minimal').
default_include=$(minimal_include)
default_exclude=$(minimal_exclude)

TEMPLATE=src/policy.yaml.tmpl

ifndef GOMPLATE
	GOMPLATE=gomplate
endif

%/policy.yaml: $(TEMPLATE) Makefile
	@mkdir -p $(*)
	@env NAME=$(*) \
	  DESCRIPTION='$($(*)_description)' \
	  INCLUDE='$($(*)_include)' \
	  EXCLUDE='$($(*)_exclude)' \
	  $(GOMPLATE) --file $< > $@

POLICY_FILES=\
  default/policy.yaml \
  minimal/policy.yaml \
  slsa1/policy.yaml \
  slsa2/policy.yaml \
  slsa3/policy.yaml \
  everything/policy.yaml

all: $(POLICY_FILES)

clean:
	@rm -rf $(POLICY_FILES)

refresh: clean all

# Should produce an error if any policy files are not in sync with the template
update-needed-check:
	@$(MAKE) --no-print-directory refresh
	@if [ -n "$$(git diff --name-only -- $(POLICY_FILES))" ]; then echo "Stale generated files found. Refresh needed."; exit 1; fi

# Should produce an error if there is any invalid yaml
yaml-parse-check:
	@git ls-files '*.yaml' | xargs -n1 yq > /dev/null

ci: update-needed-check yaml-parse-check

# See https://docs.gomplate.ca/installing/ for other installation methods
install-gomplate:
	go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
