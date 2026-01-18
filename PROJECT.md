# Community Learning Platform - Project Details

**Project Name:** VHT Community Learning Platform  
**Author:** Charles Herbert Matovu  
**Creation Year:** 2025  
**Location:** Uganda

## Vision

Create an accessible, peer-to-peer learning platform that empowers:
- **Village Health Teams (VHT)** across Uganda
- **Women Groups** in local communities
- Community members seeking health and skill development knowledge

## Key Features

### For VHT Networks
- Knowledge sharing and resource library
- Training material repositories
- Community health best practices
- Peer learning groups

### For Women Groups
- Skills development resources
- Economic empowerment content
- Health and wellness information
- Networking opportunities

### Technical Implementation
- Cloud-based infrastructure (Google Cloud Platform)
- Automated deployment via GitHub Actions
- Infrastructure as Code using Terraform
- Scalable and cost-effective architecture

## Technology Stack

### Infrastructure
- **Cloud Provider:** Google Cloud Platform (GCP)
- **Storage:** Google Cloud Storage (GCS)
- **IaC Tool:** Terraform
- **CI/CD:** GitHub Actions
- **Version Control:** GitHub

### Project Structure
```
cicd-terraform/
├── Infrastructure configuration
├── GitHub Actions workflows
├── Terraform modules
└── Documentation
```

## Deployment Pipeline

```
Code Push → Validate → Plan → Approve → Apply → Monitor
```

1. **Validate**: Syntax and format checks
2. **Plan**: Show proposed infrastructure changes
3. **Review**: Team approval in PR
4. **Apply**: Automated deployment to GCP
5. **Monitor**: Track infrastructure and costs

## Getting Started

See [DEPLOYMENT.md](DEPLOYMENT.md) for step-by-step setup instructions.

### Quick Links
- Main Documentation: [README.md](README.md)
- Deployment Guide: [DEPLOYMENT.md](DEPLOYMENT.md)
- Terraform Configuration: [main.tf](main.tf)
- Variables: [variables.tf](variables.tf)

## Community Impact

This platform aims to:
- 📚 Democratize access to learning resources
- 👩‍⚕️ Support healthcare delivery at community level
- 👥 Strengthen community networks
- 💪 Empower women economically and socially
- 🌍 Contribute to SDG 3 & 5 (Health & Gender Equality)

## Contributing

Community members and developers are welcome to:
- Report issues and improvements
- Share feedback and use cases
- Contribute to platform development
- Help with documentation

## Support

For questions or support:
1. Check documentation
2. Review examples in [terraform.tfvars.example](terraform.tfvars.example)
3. Consult [DEPLOYMENT.md](DEPLOYMENT.md)
4. Open a GitHub issue

---

**Made with ❤️ for Communities in Uganda**  
*Building accessible digital infrastructure for local empowerment*
