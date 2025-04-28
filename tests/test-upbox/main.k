import models.io.upbound.aws.ec2.v1beta1 as ec2v1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: ""
        spec= {
            assertResources: [
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "Upbox"
                    metadata = {
                        name = "example"
                    }
                }
                ec2v1beta1.Instance{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "instance"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                            "upbox.aws.platform.upbound.io/id" = "upbox-mmc-example"
                            "upbox.aws.platform.upbound.io/owner" = "team-platform"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        forProvider = {
                            ami = "ami-0ed58ee98310859ee"
                            associatePublicIpAddress = True
                            instanceType = "t4g.micro"
                            keyName = "upbox-mmc-example"
                            region = "us-west-2"
                            subnetIdSelector = {
                                matchLabels = {
                                    access = "public"
                                    "networks.aws.platform.upbound.io/network-id" = "upbox-aws-network"
                                    zone = "us-west-2a"
                                }
                            }
                            tags = {
                                Name = "upbox-mmc-example"
                            }
                            vpcSecurityGroupIdSelector = {
                                matchControllerRef = True
                            }
                        }
                        managementPolicies = [
                            "*"
                        ]
                        providerConfigRef = {
                            name = "default"
                        }
                    }
                }
                ec2v1beta1.KeyPair{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "key"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                            "upbox.aws.platform.upbound.io/id" = "upbox-mmc-example"
                        }
                        name = "upbox-mmc-example"
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        forProvider = {
                            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoZQbAbTmEQmFzsRwY1Qc9WEY3EPuryShqu1whWYCDt tobias.kasser@upbound.io"
                            region = "us-west-2"
                        }
                        managementPolicies = [
                            "*"
                        ]
                        providerConfigRef = {
                            name = "default"
                        }
                    }
                }
                ec2v1beta1.SecurityGroup{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sg"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        forProvider = {
                            description = "Allow all access"
                            name = "upbox-mmc-example"
                            region = "us-west-2"
                            vpcIdSelector = {
                                matchLabels = {
                                    "networks.aws.platform.upbound.io/network-id" = "upbox-aws-network"
                                }
                            }
                        }
                        managementPolicies = [
                            "*"
                        ]
                    }
                }
                ec2v1beta1.SecurityGroupRule{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sgr-outbound-all"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        forProvider = {
                            cidrBlocks = [
                                "0.0.0.0/0"
                            ]
                            description = "Allow all outbound traffic"
                            fromPort = 0
                            $protocol = "-1"
                            region = "us-west-2"
                            securityGroupIdSelector = {
                                matchControllerRef = True
                            }
                            toPort = 0
                            $type = "egress"
                        }
                        managementPolicies = [
                            "*"
                        ]
                    }
                }
                ec2v1beta1.SecurityGroupRule{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "sgr-ssh"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        forProvider = {
                            cidrBlocks = [
                                "0.0.0.0/0"
                            ]
                            description = "SSH access from everywhere"
                            fromPort = 22
                            $protocol = "tcp"
                            region = "us-west-2"
                            securityGroupIdSelector = {
                                matchControllerRef = True
                            }
                            toPort = 22
                            $type = "ingress"
                        }
                        managementPolicies = [
                            "*"
                        ]
                    }
                }
            ]
            extraResources = [
                ec2v1beta1.VPC{
                    metadata = {
                        labels = {
                            "networks.aws.platform.upbound.io/network-id" = "upbox-aws-network"
                        }
                        name = "some-vpc"
                    }
                    spec = {
                        forProvider = {
                            region = "us-west-2"
                        }
                    }
                }
            ]
            compositionPath: "apis/upboxes/composition.yaml"
            xrPath: "examples/upbox/example.yaml"
            xrdPath: "apis/upboxes/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
