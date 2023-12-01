// derived from upstream helm-release-def.cue

output: {
	apiVersion: "helm.toolkit.fluxcd.io/v2beta1"
	kind:       "HelmRelease"
	metadata: {
		name: context.name
	}
	spec: {
		timeout:  parameter.installTimeout
		interval: parameter.pullInterval
		chart: {
			spec: {
				chart:   parameter.chart
				version: parameter.version
				if parameter.sourceRef != _|_ {
					if parameter.sourceRef != null {
						sourceRef: parameter.sourceRef
					}
				}
				if parameter.sourceRef == _|_ {
					sourceRef: {
						// FIXME: is any of this actually used?
						if parameter.repoType == "git" {
							kind: "GitRepository"
						}
						if parameter.repoType == "helm" || parameter.repoType == "oci" {
							kind: "HelmRepository"
						}
						if parameter.repoType == "oss" {
							kind: "Bucket"
						}
						if parameter.sourceName == _|_ {
							name: context.name
						}
						if parameter.sourceName != _|_ {
							name: parameter.sourceName
						}
					}
				}
				interval: parameter.interval
				if parameter["valuesFiles"] != _|_ {
					valuesFiles: parameter["valuesFiles"]
				}
			}
		}
		if parameter.dependsOn != _|_ {
			dependsOn: parameter.dependsOn
		}
		if parameter.targetNamespace != _|_ {
			targetNamespace: parameter.targetNamespace
		}
		if parameter.releaseName != _|_ {
			releaseName: parameter.releaseName
		}
		if parameter.values != _|_ {
			values: parameter.values
		}
		if parameter.valuesFrom != _|_ {
			valuesFrom: parameter.valuesFrom
		}
		install: {
			if parameter.install.crds != _|_ {
				crds: parameter.install.crds
			}
			remediation: {
				if parameter.install.remediation.retries != _|_ {
					retries: parameter.install.remediation.retries
				}
				if parameter.install.remediation.ignoreTestfailures != _|_ {
					ignoreTestfailures: parameter.install.remediation.ignoreTestfailures
				}
				if parameter.install.remediation.remediateLastFailure != _|_ {
					remediateLastFailure: parameter.install.remediation.remediateLastFailure
				}
			}
			createNamespace: (parameter.install.createNamespace & string | parameter.createNamespace)
			if parameter.install.disableWait != _|_ {
				disableWait: parameter.install.disableWait
			}
			if parameter.install.disableWaitForJobs != _|_ {
				disableWaitForJobs: parameter.install.disableWaitForJobs
			}
			if parameter.install.disableHooks != _|_ {
				disableHooks: (parameter.install.disableHooks)
			}
			if parameter.install.replace != _|_ {
				replace: parameter.install.replace
			}
			if parameter.install.crds != _|_ {
				crds: parameter.install.crds
			}
			if parameter.install.timeout != _|_ {
				timeout: parameter.install.timeout
			}

		}
		upgrade: {
			if parameter.upgrade.crds != _|_ {
				crds: parameter.upgrade.crds
			}
			remediation: {
				if parameter.upgrade.remediation.retries != _|_ {
					retries: parameter.upgrade.remediation.retries
				}
				if parameter.upgrade.remediation.ignoreTestfailures != _|_ {
					ignoreTestfailures: parameter.upgrade.remediation.ignoreTestfailures
				}
				if parameter.upgrade.remediation.remediateLastFailure != _|_ {
					remediateLastFailure: parameter.upgrade.remediation.remediateLastFailure
				}
			}
			if parameter.upgrade.disableWait != _|_ {
				disableWait: parameter.upgrade.disableWait
			}
			if parameter.upgrade.disableWaitForJobs != _|_ {
				disableWaitForJobs: parameter.upgrade.disableWaitForJobs
			}
			if parameter.upgrade.disableHooks != _|_ {
				disableHooks: parameter.upgrade.disableHooks
			}
			if parameter.upgrade.crds != _|_ {
				crds: parameter.upgrade.crds
			}
			if parameter.upgrade.timeout != _|_ {
				timeout: parameter.upgrade.timeout
			}
			if parameter.upgrade.force != _|_ {
				force: parameter.upgrade.force
			}
		}
	}
}

_secret: {
	if parameter.secretRef != _|_ {
		if parameter.secretRef != "" {
			secretRef: {
				name: parameter.secretRef
			}
		}
	}
}

_sourceCommonArgs: {
	interval: parameter.pullInterval
	if parameter.timeout != _|_ {
		timeout: parameter.timeout
	}
}

parameter: {
	repoType: *"helm" | "git" | "oss" | "oci"
	// +usage=The interval at which to check for repository/bucket and release updates, default to 5m
	pullInterval: *"5m" | string
	// +usage=The  Interval at which to reconcile the Helm release, default to 30s
	interval: *"30s" | string
	// +usage=The Git or Helm repository URL, OSS endpoint, accept HTTP/S or SSH address as git url,
	url: string
	// +usage=The name of the secret containing authentication credentials
	secretRef?: string
	// +usage=The timeout for operations like download index/clone repository, optional
	timeout?: string
	// +usage=The timeout for operation `helm install`, optional
	installTimeout: *"10m" | string
	// +usage=The name of the source already existed
	sourceName?: string

	git?: {
		// +usage=The Git reference to checkout and monitor for changes, defaults to main branch
		branch: *"main" | string
	}
	oss?: {
		// +usage=The bucket's name, required if repoType is oss
		bucketName: string
		// +usage="generic" for Minio, Amazon S3, Google Cloud Storage, Alibaba Cloud OSS, "aws" for retrieve credentials from the EC2 service when credentials not specified, default "generic"
		provider: *"generic" | "aws"
		// +usage=The bucket region, optional
		region?: string
	}

	// +usage=ValuesFrom holds references to resources containing Helm values for this HelmRelease,
	// and information about how they should be merged.
	valuesFrom?: [...{
		// +usage=kind of the values referent, valid values are ('Secret', 'ConfigMap').
		kind: string
		// +usage=name of the values referent. Should reside in the same namespace as the referring resource
		name: string
		// +usage=ValuesKey is the data key where the values.yaml or a specific value can be
		// found at. Defaults to 'values.yaml'.
		// +optional
		valuesKey?: string

		// +usage=TargetPath is the YAML dot notation path the value should be merged at. When
		// set, the ValuesKey is expected to be a single flat value. Defaults to 'None',
		// which results in the values getting merged at the root.
		targetPath?: string

		// +usage=Optional marks this ValuesReference as optional. When set, a not found error
		// for the values reference is ignored, but any ValuesKey, TargetPath or
		// transient error will still result in a reconciliation failure.
		optional?: bool
	}]

	// +usage=Alternative list of values files to use as the chart values (values.yaml is not included by default), expected to be a relative path in the SourceRef.Values files are merged in the order of this list with the last file overriding the first.
	valuesFiles?: [...string]

	// +usage=1.The relative path to helm chart for git/oss source. 2. chart name for helm resource 3. relative path for chart package(e.g. ./charts/podinfo-1.2.3.tgz)
	chart: string
	// +usage=Chart version
	version: *"*" | string
	// +usage=The namespace for helm chart, optional
	createNamespace?: bool
	// +usage=The namespace for helm chart, optional
	targetNamespace?: string
	// +usage=The release name
	releaseName?: string
	// +usage=Disable hooks when helm install/upgrade failure
	// FIXME: remove for install.disableHooks
	disableHooks?: bool
	// +usage=Retry times when install/upgrade fail.
	dependsOn?: [...{
		name:       string
		namespace?: string
	}]
	// +usage=Chart values
	values?: #nestedmap
	install?: {
		// +usage=https://github.com/fluxcd/helm-controller/blob/main/docs/api/helmrelease.md#install
		crds?:            "Skip" | *"Create" | "CreateReplace"
		createNamespace?: bool
		timeout?:         string
		remediation?: {
			retries?:              *3 | int
			ignoreTestFailures?:   bool
			remediateLastFailure?: bool
		}
		disableWait?:        bool
		disableWaitForJobs?: bool
		disableHooks?:       bool
		replace?:            bool
		// +usage=https://github.com/fluxcd/helm-controller/blob/main/docs/api/helmrelease.md#helm.toolkit.fluxcd.io/v2beta1.InstallRemediation
		remediation?: {
			retries?:              int
			ignoreTestFailures?:   bool
			remediateLastFailure?: bool
		}
	}
	upgrade?: {
		// +usage=https://fluxcd.io/flux/components/helm/helmreleases/#crds
		crds?:               *"Skip" | "Create" | "CreateReplace"
		timeout?:            string
		disableWait?:        bool
		disableWaitForJobs?: bool
		disableHooks?:       bool
		force?:              bool
		cleanupOnFail?:      bool
		remediation?: {
			retries?:              *3 | int
			ignoreTestFailures?:   bool
			remediateLastFailure?: bool
			strategy?:             "rollback"
		}
	}
}

#nestedmap: {
	...
}
