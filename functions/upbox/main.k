import models.io.upbound.aws.ec2.v1beta1 as ec2v1beta1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1

oxr = platformawsv1alpha1.Upbox {**option("params").oxr}
_ocds = option("params").ocds
extraResources = option("params")?.extraResources

_metadata = lambda name: str -> any {
    {
        annotations = {"krm.kcl.dev/composition-resource-name" = name}
    }
}

id = "upbox-{}-{}".format(oxr.spec.parameters.company, oxr.metadata.name)

_vpc = Undefined

if extraResources.vpc:
    assert len(extraResources.vpc) == 1, "Error: more than one VPC matches specified labels!"
    _vpc = ec2v1beta1.VPC{**extraResources.vpc[0].Resource} or Undefined

_items = []

_items = [
    platformawsv1alpha1.Upbox {
        spec = {
            parameters = {
                company = oxr.spec.parameters.company
                owner = oxr.spec.parameters.owner
                publicKey = oxr.spec.parameters.publicKey
            }
        }
        status = {
            id = id
            instanceId = _ocds.instance?.Resource?.status?.atProvider?.id or ""
            publicIp = _ocds.instance?.Resource?.status?.atProvider?.publicIp or ""
        }
    }
    # pull region from network
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            vpc = {
                apiVersion = "ec2.aws.upbound.io/v1beta1"
                kind = "VPC"
                matchLabels = {
                    "networks.aws.platform.upbound.io/network-id" = oxr.spec.parameters.networkId
                }
            }
        }
    }
]

if _vpc:
    _items += [
        ec2v1beta1.Instance {
            metadata = {
                **_metadata("instance")
                labels = {
                    "upbox.aws.platform.upbound.io/id" = id
                    "upbox.aws.platform.upbound.io/owner" = oxr.spec.parameters.owner
                }
            }
            spec = {
                forProvider = {
                    region = _vpc.spec.forProvider.region
                    instanceType = "t4g.{}".format(oxr.spec.parameters.size)
                    associatePublicIpAddress = True
                    subnetIdSelector = {
                        matchLabels = {
                            "networks.aws.platform.upbound.io/network-id" = oxr.spec.parameters.networkId
                            access = "public"
                            zone = "{}{}".format(_vpc.spec.forProvider.region, oxr.spec.parameters.zone)
                        }
                    }
                    vpcSecurityGroupIdSelector = {
                        matchControllerRef = True
                    }
                    ami = oxr.spec.parameters.amiId
                    keyName = id
                    tags = {
                        Name = id
                    }
                }
                providerConfigRef = {
                    name = oxr.spec.parameters.providerConfigName
                }
            }
        }
        ec2v1beta1.SecurityGroup {
            metadata = _metadata("sg")
            spec = {
                forProvider = {
                    description = "Allow all access"
                    name = id
                    vpcIdSelector = {
                        matchLabels = {
                            "networks.aws.platform.upbound.io/network-id" = oxr.spec.parameters.networkId
                        }
                    }
                    region = _vpc.spec.forProvider.region
                }
                providerConfigRef = {
                    name = oxr.spec.parameters.providerConfigName
                }
            }
        }
        ec2v1beta1.SecurityGroupRule {
            metadata = _metadata("sgr-ssh")
            spec = {
                forProvider = {
                    cidrBlocks = [
                        "0.0.0.0/0"
                    ]
                    description = "SSH access from everywhere"
                    fromPort = 22
                    protocol = "tcp"
                    securityGroupIdSelector = {
                        matchControllerRef = True
                    }
                    toPort = 22
                    type = "ingress"
                    region = _vpc.spec.forProvider.region
                }
                providerConfigRef = {
                    name = oxr.spec.parameters.providerConfigName
                }
            }
        }
        ec2v1beta1.SecurityGroupRule {
            metadata = _metadata("sgr-outbound-all")
            spec = {
                forProvider = {
                    cidrBlocks = [
                        "0.0.0.0/0"
                    ]
                    description = "Allow all outbound traffic"
                    fromPort = 0
                    protocol = "-1"
                    securityGroupIdSelector = {
                        matchControllerRef = True
                    }
                    toPort = 0
                    type = "egress"
                    region = _vpc.spec.forProvider.region
                }
                providerConfigRef = {
                    name = oxr.spec.parameters.providerConfigName
                }
            }
        }
        ec2v1beta1.KeyPair {
            metadata = {
                **_metadata("key")
                name = id
                labels = {
                    "upbox.aws.platform.upbound.io/id" = id
                }
            }
            spec = {
                forProvider = {
                    publicKey = oxr.spec.parameters.publicKey
                    region = _vpc.spec.forProvider.region
                }
                providerConfigRef = {
                    name = oxr.spec.parameters.providerConfigName
                }
            }
        }
    ]

items = _items
