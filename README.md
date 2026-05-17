# Upbox

Upbox is a solution for providing automated cloud lab environments for 3rd Party Developers and Training Attendees.

## Prerequisites

- AWS Provider Configuration
- XNetwork resource (provides VPC, subnet, and security group infrastructure)

## Quick Start

1. Set up the network infrastructure:
   ```bash
   kubectl apply -f examples/configuration-aws-network.yaml
   kubectl apply -f examples/xnetwork.yaml
   ```

2. Create an UpboxSet (for training sessions) or individual Upboxes:
   ```bash
   # For a training session with multiple participants
   kubectl apply -f examples/upboxset/example.yaml
   
   # For an individual lab environment
   kubectl apply -f examples/upbox/example.yaml
   ```

## Network

The Upbox resources link to the XNetwork infrastructure using a network ID parameter. When creating an Upbox or UpboxSet, you need to reference the network via the `networkId` parameter.

### Network Reference

In your Upbox or UpboxSet configuration, include a reference to the network ID:

```yaml
# Sample configuration showing network reference
spec:
  parameters:
    networkId: upbox-aws-network
```

This parameter links the Upbox resources to the correct network infrastructure.

### Network Trace

After claiming the network a trace should show the following:

```
crossplane beta trace xnetwork.aws.platform.upbound.io/upbox-aws-network
NAME                                                   SYNCED   READY   STATUS
XNetwork/upbox-aws-network                             True     True    Available
├─ InternetGateway/upbox-aws-network-4p2vp             True     True    Available
├─ MainRouteTableAssociation/upbox-aws-network-nzfsc   True     True    Available
├─ RouteTableAssociation/upbox-aws-network-bdtrr       True     True    Available
├─ RouteTable/upbox-aws-network-k98zs                  True     True    Available
├─ Route/upbox-aws-network-9w9cm                       True     True    Available
├─ SecurityGroupRule/upbox-aws-network-2825b           True     True    Available
├─ SecurityGroupRule/upbox-aws-network-2sgz5           True     True    Available
├─ SecurityGroupRule/upbox-aws-network-d4b27           True     True    Available
├─ SecurityGroupRule/upbox-aws-network-nwb2k           True     True    Available
├─ SecurityGroup/upbox-aws-network-g95d2               True     True    Available
├─ Subnet/upbox-aws-network-lv5zt                      True     True    Available
└─ VPC/upbox-aws-network-zjdlc                         True     True    Available
```

## Upbox Resources

### UpboxSet

The `UpboxSet` resource provides a way to create multiple Upboxes for a training session or group environment. It automatically creates individual Upbox resources for each user based on the configuration provided.

Key features:
- Creates multiple Upboxes in a single resource
- All Upboxes share the same network infrastructure
- Users are specified with their SSH public keys

Example UpboxSet configuration:
```yaml
apiVersion: aws.platform.upbound.io/v1alpha1
kind: UpboxSet
metadata:
  name: example
spec:
  parameters:
    company: upbound
    owner: team-solutions
    networkId: upbox-aws-network
    users:
      tobias:
        publicKey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
      yury:
        publicKey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
```

The UpboxSet controller creates individual Upboxes for each user with their respective SSH keys.

Trace command:
```
$> crossplane beta trace upboxset example
NAME                                                        SYNCED   READY   STATUS
UpboxSet/example                                            True     True    Available
├─ Upbox/upbound-team-solutions-tobias                      True     True    Available
│  ├─ Instance/example-sk982                                True     True    Available
│  ├─ KeyPair/upbox-upbound-upbound-team-solutions-tobias   True     True    Available
│  ├─ SecurityGroupRule/example-k85l7                       True     True    Available
│  ├─ SecurityGroupRule/example-wmg2t                       True     True    Available
│  └─ SecurityGroup/example-zhps7                           True     True    Available
└─ Upbox/upbound-team-solutions-yury                        True     True    Available
   ├─ Instance/example-5qjz5                                True     True    Available
   ├─ KeyPair/upbox-upbound-upbound-team-solutions-yury     True     True    Available
   ├─ SecurityGroupRule/example-8zwhl                       True     True    Available
   ├─ SecurityGroupRule/example-tnj2z                       True     True    Available
   └─ SecurityGroup/example-zs2rw                           True     True    Available
```

### Individual Upbox

An `Upbox` resource creates a single lab environment with an EC2 instance and associated resources.

Example Upbox configuration:
```yaml
apiVersion: aws.platform.upbound.io/v1alpha1
kind: Upbox
metadata:
  name: upbound-team-solutions-tobias
spec:
  parameters:
    company: upbound
    owner: team-solutions
    networkId: upbox-aws-network
    publicKey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..."
```

Trace command:
```
$> crossplane beta trace upbox upbound-team-solutions-tobias
NAME                                                     SYNCED   READY   STATUS
Upbox/upbound-team-solutions-tobias                      True     True    Available
├─ Instance/example-sk982                                True     True    Available
├─ KeyPair/upbox-upbound-upbound-team-solutions-tobias   True     True    Available
├─ SecurityGroupRule/example-k85l7                       True     True    Available
├─ SecurityGroupRule/example-wmg2t                       True     True    Available
└─ SecurityGroup/example-zhps7                           True     True    Available
```

### Access Info

You can retrieve the SSH connection information for Upboxes by filtering with labels:

```bash
COMPANY=upbound OWNER=team-solutions
kubectl get upbox \
    -l upbox.aws.platform.upbound.io/company=$COMPANY \
    -l upbox.aws.platform.upbound.io/owner=$OWNER -oyaml \
    | yq '.items[] | "\(.metadata.name): \"ssh ubuntu@\(.status.publicIp)\""'
```

## Claude Code

Each Upbox comes with Claude Code pre-installed. After connecting via SSH, authenticate and optionally set up the Upbound marketplace:

```bash
# Authenticate with your Claude.ai subscription
BROWSER=echo claude

# Authenticate gh CLI (needed for private marketplace access)
gh auth login

# Add the Upbound Claude marketplace
claude plugin marketplace add upbound/claude-marketplace
```

SSH with agent forwarding is recommended so `gh` can use your local SSH key:

```bash
ssh -A ubuntu@<public-ip>
```

## Architecture

Upbox uses Crossplane compositions to create managed AWS resources:

- `UpboxSet` - Creates multiple Upboxes for a training session
- `Upbox` - Creates an individual lab environment with EC2 instance and security group
- `XNetwork` - Creates the underlying VPC network infrastructure

## AMI Automation

The AMI images used for Upboxes are automatically built and updated:

- Built using Packer automation
- AMI IDs are tracked in GitHub Actions workflow runs
- CI/CD with GitHub Actions:
  - Pull requests build on staging account (crossplane playground)
  - Main branch builds on production account (upbox)
  
For the latest AMI ID to use in your configurations, check the most recent workflow run in GitHub Actions.

## Troubleshooting

If you encounter issues with your Upbox environments:

1. Check the resource status with `crossplane beta trace`
2. Verify networking setup is complete
3. Ensure AWS provider is properly configured
