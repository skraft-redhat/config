
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

%/policy.yaml: $(TEMPLATE) Makefile
	@mkdir -p $(*)
	@env NAME=$(*) \
	  DESCRIPTION='$($(*)_description)' \
	  INCLUDE='$($(*)_include)' \
	  EXCLUDE='$($(*)_exclude)' \
	  gomplate --file $< > $@

POLICY_FILES=\
  default/policy.yaml \
  minimal/policy.yaml \
  slsa1/policy.yaml \
  slsa2/policy.yaml \
  slsa3/policy.yaml \
  everything/policy.yaml

all: $(POLICY_FILES)

# See https://docs.gomplate.ca/installing/ for other installation methods
install-gomplate:
	go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
