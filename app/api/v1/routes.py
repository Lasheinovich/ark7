from fastapi import APIRouter
from app.api.v1 import (
    rca7_routes,
    financial_routes,
    education_routes,
    health_routes,
    governance_routes,
    life_routes,
    spiritual_routes
)

api_router = APIRouter()

# Include all feature-specific routers with summaries
def include_with_summary(router, prefix, tag, summary):
    api_router.include_router(
        router,
        prefix=prefix,
        tags=[tag],
        responses={200: {"description": summary}}
    )

include_with_summary(rca7_routes.router, "/rca7", "RCA7", "Root Cause Analysis Intelligence (7 Layers of Causality)")
include_with_summary(financial_routes.router, "/financial", "Financial AI", "AI for Wealth Generation & Decentralized Finance")
include_with_summary(education_routes.router, "/education", "Education AI", "Adaptive AI Tutor & Universal Knowledge")
include_with_summary(health_routes.router, "/health", "Health AI", "7-Based Biohacking & Predictive Health")
include_with_summary(governance_routes.router, "/governance", "Governance AI", "Decentralized Ethics-based Global Intelligence")
include_with_summary(life_routes.router, "/life", "Life Optimization", "Life Growth & Optimization AI")
include_with_summary(spiritual_routes.router, "/spiritual", "Spiritual AI", "Spiritual Growth & Enlightenment AI")

# Return api_router so it can be used in main.py
router = api_router
