package test

import (
	// "context"
	// "fmt"
	"strings"
	"testing"

	"github.com/cloudposse/test-helpers/pkg/atmos"
	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	// awshelper "github.com/cloudposse/test-helpers/pkg/aws"
	// "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
	// "github.com/stretchr/testify/require"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "saml/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)
	assert.NotNil(s.T(), options)

	samlProviderArns := atmos.OutputMap(s.T(), options, "saml_provider_arns")
	assert.Equal(s.T(), 1, len(samlProviderArns))
	assert.True(s.T(), strings.HasPrefix(samlProviderArns["example-gsuite"], "arn:aws:iam::"))

	oktaApiUsers := atmos.OutputMap(s.T(), options, "okta_api_users")
	assert.Empty(s.T(), oktaApiUsers)

	samlProviderAssumeRolePolicy := atmos.Output(s.T(), options, "saml_provider_assume_role_policy")
	assert.NotEmpty(s.T(), samlProviderAssumeRolePolicy)

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "saml/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func TestRunVPCSuite(t *testing.T) {
	suite := new(ComponentSuite)
	helper.Run(t, suite)
}
